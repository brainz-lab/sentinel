module Mcp
  module Tools
    class HostStatus < Base
      TOOL_NAME = 'sentinel_host_status'
      DESCRIPTION = 'Get detailed status of a specific host'

      SCHEMA = {
        type: 'object',
        properties: {
          host_name: {
            type: 'string',
            description: 'Host name'
          }
        },
        required: ['host_name']
      }.freeze

      def call(args)
        host = hosts.find_by!(name: args[:host_name])
        health = HostHealthChecker.new(host).check

        {
          name: host.name,
          status: health[:status],
          issues: health[:issues],

          system: {
            os: "#{host.os} #{host.os_version}",
            kernel: host.kernel_version,
            cpu_model: host.cpu_model,
            cpu_cores: host.cpu_cores,
            memory_gb: host.memory_total_gb,
            uptime: host.uptime_humanized
          },

          current_metrics: {
            cpu_percent: host.current_cpu.round(1),
            memory_percent: host.current_memory.round(1),
            load_1m: host.current_load.round(2)
          },

          disks: host.disk_usage.map do |d|
            {
              mount: d.mount_point,
              usage_percent: d.usage_percent&.round(1),
              free_gb: d.free_gb
            }
          end,

          containers: host.containers.running.count,

          cloud: {
            provider: host.cloud_provider,
            region: host.cloud_region,
            instance_type: host.instance_type
          }
        }
      end
    end
  end
end
