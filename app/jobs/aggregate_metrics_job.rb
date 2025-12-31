class AggregateMetricsJob < ApplicationJob
  queue_as :default

  def perform(project_id = nil)
    if project_id
      aggregate_for_project(project_id)
    else
      Host.distinct.pluck(:platform_project_id).each do |pid|
        aggregate_for_project(pid)
      end
    end
  end

  private

  def aggregate_for_project(project_id)
    analyzer = FleetAnalyzer.new(project_id)
    overview = analyzer.overview
    capacity = analyzer.capacity_summary

    # Broadcast fleet stats to dashboard
    ActionCable.server.broadcast(
      "hosts_#{project_id}",
      {
        type: "fleet_stats",
        overview: overview,
        capacity: capacity,
        updated_at: Time.current
      }
    )

    # Log for monitoring
    Rails.logger.info "[Sentinel] Fleet stats for #{project_id}: #{overview[:total_hosts]} hosts, " \
                      "#{overview[:online]} online, avg CPU: #{overview.dig(:resources, :avg_cpu)}%"
  end
end
