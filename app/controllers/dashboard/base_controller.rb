module Dashboard
  class BaseController < ActionController::Base
    include ActionController::Cookies

    before_action :require_session!, unless: -> { Rails.env.development? }
    before_action :set_current_project
    helper_method :current_user, :current_project

    layout "dashboard"

    private

    def require_session!
      unless session[:user_id].present? && session[:expires_at].to_i > Time.current.to_i
        redirect_to sso_login_url, allow_other_host: true
      end
    end

    def current_user
      @current_user ||= OpenStruct.new(
        id: session[:user_id] || 'dev-user',
        email: session[:email] || 'dev@example.com',
        name: session[:name] || 'Developer',
        organization_id: session[:organization_id]
      )
    end

    def set_current_project
      if params[:project_id].present?
        @current_project = Project.find(params[:project_id])
        session[:current_project_id] = @current_project.id
      elsif session[:current_project_id].present?
        @current_project = Project.find_by(id: session[:current_project_id])
      end
    end

    def current_project
      @current_project
    end

    def require_project!
      unless current_project
        redirect_to dashboard_root_path, alert: "Please select a project"
      end
    end

    def sso_login_url
      platform_url = ENV["BRAINZLAB_PLATFORM_URL"] || "http://platform.localhost:2999"
      return_url = CGI.escape(request.original_url)
      "#{platform_url}/login?return_to=#{return_url}&app=sentinel"
    end
  end
end
