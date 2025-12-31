module Mcp
  module Tools
    class FleetOverview < Base
      TOOL_NAME = "sentinel_fleet_overview"
      DESCRIPTION = "Get overview of all hosts in the fleet"

      SCHEMA = {
        type: "object",
        properties: {}
      }.freeze

      def call(args)
        analyzer = FleetAnalyzer.new(@project_id)
        overview = analyzer.overview
        capacity = analyzer.capacity_summary

        {
          hosts: {
            total: overview[:total_hosts],
            online: overview[:online],
            offline: overview[:offline],
            warning: overview[:warning],
            critical: overview[:critical]
          },
          by_environment: overview[:by_environment],
          by_role: overview[:by_role],
          resources: {
            avg_cpu: overview[:resources][:avg_cpu],
            avg_memory: overview[:resources][:avg_memory],
            avg_load: overview[:resources][:avg_load]
          },
          capacity: {
            total_cpu_cores: capacity[:total_cpu_cores],
            total_memory_gb: capacity[:total_memory_gb],
            cpu_headroom: capacity[:headroom][:cpu_headroom],
            memory_headroom: capacity[:headroom][:memory_headroom]
          },
          top_cpu: overview[:top_cpu],
          top_memory: overview[:top_memory]
        }
      end
    end
  end
end
