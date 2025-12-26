module Mcp
  module Tools
    class HostMetrics < Base
      TOOL_NAME = 'sentinel_host_metrics'
      DESCRIPTION = 'Get metrics history for a host'

      SCHEMA = {
        type: 'object',
        properties: {
          host_name: {
            type: 'string',
            description: 'Host name'
          },
          metric: {
            type: 'string',
            enum: ['cpu', 'memory', 'load', 'disk', 'network'],
            default: 'cpu'
          },
          period: {
            type: 'string',
            enum: ['1h', '6h', '24h', '7d'],
            default: '24h'
          }
        },
        required: ['host_name']
      }.freeze

      def call(args)
        host = hosts.find_by!(name: args[:host_name])
        period = parse_period(args[:period])
        metric = args[:metric] || 'cpu'

        case metric
        when 'cpu'
          { series: host.host_metrics.cpu_series(period: period) }
        when 'memory'
          { series: host.host_metrics.memory_series(period: period) }
        when 'load'
          { series: host.host_metrics.load_series(period: period) }
        when 'disk'
          { disks: disk_metrics(host, period) }
        when 'network'
          { interfaces: network_metrics(host, period) }
        else
          { error: "Unknown metric: #{metric}" }
        end
      end

      private

      def parse_period(period_str)
        case period_str
        when '1h' then 1.hour
        when '6h' then 6.hours
        when '24h' then 24.hours
        when '7d' then 7.days
        else 24.hours
        end
      end

      def disk_metrics(host, period)
        host.disk_metrics
            .where('recorded_at > ?', period.ago)
            .group(:mount_point)
            .average(:usage_percent)
            .transform_values { |v| v&.round(1) }
      end

      def network_metrics(host, period)
        host.network_metrics
            .where('recorded_at > ?', period.ago)
            .group(:interface)
            .sum(:bytes_received)
      end
    end
  end
end
