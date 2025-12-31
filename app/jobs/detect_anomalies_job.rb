class DetectAnomaliesJob < ApplicationJob
  queue_as :default

  # Simple anomaly detection using standard deviation
  ZSCORE_THRESHOLD = 2.5

  def perform(project_id = nil)
    if project_id
      detect_for_project(project_id)
    else
      Host.distinct.pluck(:platform_project_id).each do |pid|
        detect_for_project(pid)
      end
    end
  end

  private

  def detect_for_project(project_id)
    hosts = Host.for_project(project_id).online

    hosts.find_each do |host|
      anomalies = []

      anomalies.concat(check_cpu_anomaly(host))
      anomalies.concat(check_memory_anomaly(host))
      anomalies.concat(check_load_anomaly(host))

      if anomalies.any?
        broadcast_anomalies(host, anomalies)
        # TODO: Create alerts via Signal integration
      end
    end
  end

  def check_cpu_anomaly(host)
    recent = host.host_metrics.where("recorded_at > ?", 1.hour.ago).pluck(:cpu_usage_percent).compact
    historical = host.host_metrics.where("recorded_at > ?", 24.hours.ago)
                                  .where("recorded_at < ?", 1.hour.ago)
                                  .pluck(:cpu_usage_percent).compact

    detect_anomaly(host, "cpu_usage", recent, historical)
  end

  def check_memory_anomaly(host)
    recent = host.host_metrics.where("recorded_at > ?", 1.hour.ago).pluck(:memory_usage_percent).compact
    historical = host.host_metrics.where("recorded_at > ?", 24.hours.ago)
                                  .where("recorded_at < ?", 1.hour.ago)
                                  .pluck(:memory_usage_percent).compact

    detect_anomaly(host, "memory_usage", recent, historical)
  end

  def check_load_anomaly(host)
    recent = host.host_metrics.where("recorded_at > ?", 1.hour.ago).pluck(:load_1m).compact
    historical = host.host_metrics.where("recorded_at > ?", 24.hours.ago)
                                  .where("recorded_at < ?", 1.hour.ago)
                                  .pluck(:load_1m).compact

    detect_anomaly(host, "load", recent, historical)
  end

  def detect_anomaly(host, metric_name, recent, historical)
    return [] if recent.empty? || historical.size < 10

    mean = historical.sum / historical.size.to_f
    variance = historical.map { |x| (x - mean) ** 2 }.sum / historical.size.to_f
    std_dev = Math.sqrt(variance)

    return [] if std_dev == 0

    current = recent.last
    zscore = (current - mean) / std_dev

    if zscore.abs > ZSCORE_THRESHOLD
      [ {
        metric: metric_name,
        current_value: current.round(2),
        expected_mean: mean.round(2),
        std_dev: std_dev.round(2),
        zscore: zscore.round(2),
        direction: zscore > 0 ? "high" : "low"
      } ]
    else
      []
    end
  end

  def broadcast_anomalies(host, anomalies)
    ActionCable.server.broadcast(
      "hosts_#{host.platform_project_id}",
      {
        type: "anomaly_detected",
        host_id: host.id,
        host_name: host.name,
        anomalies: anomalies,
        detected_at: Time.current
      }
    )
  end
end
