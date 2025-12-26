class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  before_action :authenticate_request

  private

  def authenticate_request
    # Allow health checks without authentication
    return if request.path == '/up'

    # Check for API key in header
    api_key = request.headers['Authorization']&.sub(/^Bearer\s+/, '') ||
              request.headers['X-API-Key']

    unless api_key.present?
      render json: { error: 'API key required' }, status: :unauthorized
      return
    end

    # Validate API key and set current project
    @current_project = validate_api_key(api_key)
    unless @current_project
      render json: { error: 'Invalid API key' }, status: :unauthorized
    end
  end

  def validate_api_key(api_key)
    # In production, validate against Platform
    # For development, accept master key
    if api_key == ENV.fetch('SENTINEL_MASTER_KEY', 'bl_sentinel_master_dev_key_12345')
      OpenStruct.new(id: 'development', name: 'Development')
    else
      # TODO: Validate against Platform API
      nil
    end
  end

  def current_project
    @current_project
  end

  def skip_authentication?
    false
  end
end
