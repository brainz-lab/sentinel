class CleanupOldMetricsJob < ApplicationJob
  queue_as :low

  # Retention periods (TimescaleDB handles most of this, but we clean up orphans)
  RETENTION = {
    host_metrics: 30.days,
    disk_metrics: 30.days,
    network_metrics: 30.days,
    process_snapshots: 7.days,
    container_metrics: 14.days
  }.freeze

  def perform
    cleanup_orphaned_metrics
    cleanup_old_containers
    log_cleanup_stats
  end

  private

  def cleanup_orphaned_metrics
    # Clean up metrics for hosts that no longer exist
    host_ids = Host.pluck(:id)

    [HostMetric, DiskMetric, NetworkMetric, ProcessSnapshot].each do |model|
      deleted = model.where.not(host_id: host_ids).delete_all
      Rails.logger.info "[Sentinel] Cleaned up #{deleted} orphaned #{model.name.underscore.pluralize}" if deleted > 0
    end

    # Clean up container metrics for containers that no longer exist
    container_ids = Container.pluck(:id)
    deleted = ContainerMetric.where.not(container_id: container_ids).delete_all
    Rails.logger.info "[Sentinel] Cleaned up #{deleted} orphaned container_metrics" if deleted > 0
  end

  def cleanup_old_containers
    # Remove containers that haven't been seen in 24 hours
    deleted = Container.where('last_seen_at < ?', 24.hours.ago).destroy_all.count
    Rails.logger.info "[Sentinel] Cleaned up #{deleted} stale containers" if deleted > 0
  end

  def log_cleanup_stats
    stats = {
      host_metrics: HostMetric.count,
      disk_metrics: DiskMetric.count,
      network_metrics: NetworkMetric.count,
      process_snapshots: ProcessSnapshot.count,
      container_metrics: ContainerMetric.count
    }

    Rails.logger.info "[Sentinel] Current metric counts: #{stats.inspect}"
  end
end
