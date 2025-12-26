module Api
  module V1
    class BaseController < ApplicationController
      before_action :set_project_context

      private

      def set_project_context
        @project_id = current_project&.id || 'development'
      end
    end
  end
end
