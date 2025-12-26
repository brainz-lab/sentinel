module Api
  module V1
    class DashboardsController < BaseController
      # GET /api/v1/dashboard/fleet
      def fleet
        analyzer = FleetAnalyzer.new(@project_id)
        render json: analyzer.overview
      end

      # GET /api/v1/dashboard/capacity
      def capacity
        analyzer = FleetAnalyzer.new(@project_id)
        render json: analyzer.capacity_summary
      end
    end
  end
end
