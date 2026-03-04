module Api
  module V1
    class BaseController < ApplicationController
      before_action :set_project_context

      private

      def set_project_context
        @project_id = current_project&.id || "development"
      end

      def track_usage!(count = 1)
        return unless current_project&.platform_project_id

        PlatformClient.track_usage(
          project_id: current_project.platform_project_id,
          product: "sentinel",
          metric: "reports",
          count: count
        )
      end
    end
  end
end
