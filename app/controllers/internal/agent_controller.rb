module Internal
  class AgentController < ApplicationController
    skip_before_action :authenticate_request
    before_action :authenticate_agent

    # POST /internal/agent
    def create
      host = find_or_create_host
      MetricIngester.new(host).ingest(agent_params)

      head :ok
    end

    # POST /internal/agent/register
    def register
      host = find_or_create_host

      # Update host with registration info
      host.update!(
        os: agent_params.dig(:system_info, :os),
        os_version: agent_params.dig(:system_info, :os_version),
        kernel_version: agent_params.dig(:system_info, :kernel_version),
        architecture: agent_params.dig(:system_info, :architecture),
        cpu_model: agent_params.dig(:system_info, :cpu_model),
        cpu_cores: agent_params.dig(:system_info, :cpu_cores),
        cpu_threads: agent_params.dig(:system_info, :cpu_threads),
        memory_total_bytes: agent_params.dig(:system_info, :memory_total),
        swap_total_bytes: agent_params.dig(:system_info, :swap_total),
        ip_addresses: agent_params.dig(:system_info, :ip_addresses) || [],
        public_ip: agent_params.dig(:system_info, :public_ip),
        private_ip: agent_params.dig(:system_info, :private_ip),
        mac_addresses: agent_params.dig(:system_info, :mac_addresses) || [],
        cloud_provider: agent_params.dig(:cloud, :provider),
        cloud_region: agent_params.dig(:cloud, :region),
        cloud_zone: agent_params.dig(:cloud, :zone),
        instance_type: agent_params.dig(:cloud, :instance_type),
        instance_id: agent_params.dig(:cloud, :instance_id),
        agent_version: agent_params[:agent_version],
        agent_started_at: Time.current,
        last_seen_at: Time.current,
        status: "online"
      )

      render json: {
        host_id: host.id,
        name: host.name,
        message: "Agent registered successfully"
      }
    end

    private

    def authenticate_agent
      api_key = request.headers["Authorization"]&.sub(/^Bearer\s+/, "")

      unless api_key.present?
        render json: { error: "API key required" }, status: :unauthorized
        return
      end

      # Validate API key
      @project_id = validate_agent_api_key(api_key)
      unless @project_id
        render json: { error: "Invalid API key" }, status: :unauthorized
      end
    end

    def validate_agent_api_key(api_key)
      # In production, validate against Platform
      # For development, accept master key
      if api_key == ENV.fetch("SENTINEL_MASTER_KEY", "bl_sentinel_master_dev_key_12345")
        "development"
      else
        # TODO: Validate against Platform API
        nil
      end
    end

    def find_or_create_host
      agent_id = request.headers["X-Agent-ID"] || agent_params[:agent_id]

      Host.find_or_create_by!(platform_project_id: @project_id, agent_id: agent_id) do |host|
        host.assign_attributes(
          name: agent_params[:hostname] || agent_id,
          hostname: agent_params[:hostname] || agent_id
        )
      end
    end

    def agent_params
      @agent_params ||= params.permit!.to_h.deep_symbolize_keys
    end
  end
end
