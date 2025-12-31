module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_project_id

    def connect
      self.current_project_id = find_verified_project
    end

    private

    def find_verified_project
      # For now, accept connections with any project ID from query params
      # In production, verify against Platform
      request.params[:project_id] || "development"
    end
  end
end
