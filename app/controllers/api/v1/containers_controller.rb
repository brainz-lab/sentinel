module Api
  module V1
    class ContainersController < BaseController
      before_action :set_host
      before_action :set_container, only: [ :show ]

      # GET /api/v1/hosts/:host_id/containers
      def index
        containers = @host.containers

        # Filters
        containers = containers.where(status: params[:status]) if params[:status]

        render json: {
          containers: containers.map { |c| container_summary(c) }
        }
      end

      # GET /api/v1/hosts/:host_id/containers/:id
      def show
        render json: {
          container: container_details(@container)
        }
      end

      private

      def set_host
        @host = Host.for_project(@project_id).find(params[:host_id])
      end

      def set_container
        @container = @host.containers.find(params[:id])
      end

      def container_summary(container)
        {
          id: container.id,
          container_id: container.container_id,
          name: container.name,
          image: container.image,
          status: container.status,
          cpu_percent: container.current_cpu&.round(1),
          memory_percent: container.current_memory&.round(1),
          uptime: container.uptime_humanized
        }
      end

      def container_details(container)
        container_summary(container).merge(
          image_id: container.image_id,
          runtime: container.runtime,
          started_at: container.started_at&.iso8601,
          memory_limit_mb: container.memory_limit_mb,
          cpu_limit: container.cpu_limit,
          network_mode: container.network_mode,
          port_mappings: container.port_mappings,
          labels: container.labels,
          last_seen_at: container.last_seen_at&.iso8601
        )
      end
    end
  end
end
