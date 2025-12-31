module Api
  module V1
    class HostsController < BaseController
      before_action :set_host, only: [ :show, :update, :destroy, :metrics, :processes, :health ]

      # GET /api/v1/hosts
      def index
        hosts = Host.for_project(@project_id)

        # Filters
        hosts = hosts.by_environment(params[:environment]) if params[:environment]
        hosts = hosts.by_role(params[:role]) if params[:role]
        hosts = hosts.where(status: params[:status]) if params[:status]
        hosts = hosts.where(host_group_id: params[:group_id]) if params[:group_id]

        render json: {
          hosts: hosts.map { |h| host_summary(h) },
          total: hosts.count
        }
      end

      # GET /api/v1/hosts/:id
      def show
        render json: {
          host: host_details(@host)
        }
      end

      # GET /api/v1/hosts/:id/metrics
      def metrics
        period = (params[:hours] || 24).to_i.hours

        render json: {
          cpu: @host.host_metrics.cpu_series(period: period),
          memory: @host.host_metrics.memory_series(period: period),
          load: @host.host_metrics.load_series(period: period)
        }
      end

      # GET /api/v1/hosts/:id/processes
      def processes
        limit = params[:limit] || 20

        render json: {
          processes: @host.top_processes(limit: limit).map do |p|
            {
              pid: p.pid,
              name: p.name,
              command: p.command,
              user: p.user,
              cpu_percent: p.cpu_percent&.round(1),
              memory_percent: p.memory_percent&.round(1),
              memory_rss_mb: p.memory_rss_mb
            }
          end
        }
      end

      # GET /api/v1/hosts/:id/health
      def health
        health = HostHealthChecker.new(@host).check
        render json: health
      end

      # PATCH /api/v1/hosts/:id
      def update
        if @host.update(host_params)
          render json: { host: host_details(@host) }
        else
          render json: { errors: @host.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/hosts/:id
      def destroy
        @host.destroy!
        head :no_content
      end

      private

      def set_host
        @host = Host.for_project(@project_id).find(params[:id])
      end

      def host_params
        params.require(:host).permit(:name, :environment, :role, :host_group_id, tags: {})
      end

      def host_summary(host)
        {
          id: host.id,
          name: host.name,
          hostname: host.hostname,
          status: host.status,
          environment: host.environment,
          role: host.role,
          cpu: host.current_cpu&.round(1),
          memory: host.current_memory&.round(1),
          load: host.current_load&.round(2),
          last_seen_at: host.last_seen_at&.iso8601
        }
      end

      def host_details(host)
        {
          id: host.id,
          name: host.name,
          hostname: host.hostname,
          agent_id: host.agent_id,
          status: host.status,
          environment: host.environment,
          role: host.role,
          host_group_id: host.host_group_id,
          tags: host.tags,

          system: {
            os: host.os,
            os_version: host.os_version,
            kernel_version: host.kernel_version,
            architecture: host.architecture,
            cpu_model: host.cpu_model,
            cpu_cores: host.cpu_cores,
            cpu_threads: host.cpu_threads,
            memory_total_gb: host.memory_total_gb
          },

          cloud: {
            provider: host.cloud_provider,
            region: host.cloud_region,
            zone: host.cloud_zone,
            instance_type: host.instance_type,
            instance_id: host.instance_id
          },

          network: {
            public_ip: host.public_ip,
            private_ip: host.private_ip,
            ip_addresses: host.ip_addresses
          },

          current_metrics: {
            cpu_percent: host.current_cpu&.round(1),
            memory_percent: host.current_memory&.round(1),
            load_1m: host.current_load&.round(2)
          },

          disks: host.disk_usage.map do |d|
            {
              mount_point: d.mount_point,
              device: d.device,
              usage_percent: d.usage_percent&.round(1),
              free_gb: d.free_gb
            }
          end,

          containers_count: host.containers.running.count,

          agent: {
            version: host.agent_version,
            started_at: host.agent_started_at&.iso8601
          },

          uptime: host.uptime_humanized,
          last_seen_at: host.last_seen_at&.iso8601,
          created_at: host.created_at.iso8601,
          updated_at: host.updated_at.iso8601
        }
      end
    end
  end
end
