module Mcp
  module Tools
    class TopProcesses < Base
      TOOL_NAME = 'sentinel_top_processes'
      DESCRIPTION = 'Get top processes by CPU or memory usage'

      SCHEMA = {
        type: 'object',
        properties: {
          host_name: {
            type: 'string',
            description: 'Host name'
          },
          sort_by: {
            type: 'string',
            enum: ['cpu', 'memory'],
            default: 'cpu'
          },
          limit: {
            type: 'integer',
            default: 10
          }
        },
        required: ['host_name']
      }.freeze

      def call(args)
        host = hosts.find_by!(name: args[:host_name])
        sort_by = args[:sort_by] || 'cpu'
        limit = args[:limit] || 10

        processes = host.process_snapshots
                        .where('recorded_at > ?', 2.minutes.ago)

        processes = case sort_by
                    when 'memory'
                      processes.order(memory_percent: :desc)
                    else
                      processes.order(cpu_percent: :desc)
                    end

        processes = processes.limit(limit)

        {
          host: host.name,
          processes: processes.map do |p|
            {
              pid: p.pid,
              name: p.name,
              user: p.user,
              cpu_percent: p.cpu_percent&.round(1),
              memory_percent: p.memory_percent&.round(1),
              memory_mb: p.memory_rss_mb,
              command: p.command&.truncate(80)
            }
          end
        }
      end
    end
  end
end
