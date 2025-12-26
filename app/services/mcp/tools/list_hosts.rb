module Mcp
  module Tools
    class ListHosts < Base
      TOOL_NAME = 'sentinel_list_hosts'
      DESCRIPTION = 'List all monitored hosts and their status'

      SCHEMA = {
        type: 'object',
        properties: {
          environment: {
            type: 'string',
            description: 'Filter by environment (production, staging, etc.)'
          },
          status: {
            type: 'string',
            enum: ['online', 'offline', 'warning', 'critical'],
            description: 'Filter by status'
          },
          role: {
            type: 'string',
            description: 'Filter by role (web, worker, database, etc.)'
          }
        }
      }.freeze

      def call(args)
        result = hosts
        result = result.by_environment(args[:environment]) if args[:environment]
        result = result.by_role(args[:role]) if args[:role]
        result = result.where(status: args[:status]) if args[:status]

        {
          hosts: result.map do |h|
            {
              name: h.name,
              status: h.status,
              environment: h.environment,
              role: h.role,
              cpu: h.current_cpu.round(1),
              memory: h.current_memory.round(1),
              load: h.current_load.round(2),
              uptime: h.uptime_humanized,
              last_seen: h.last_seen_at&.iso8601
            }
          end,
          summary: {
            total: result.count,
            online: result.where(status: 'online').count,
            issues: result.with_issues.count
          }
        }
      end
    end
  end
end
