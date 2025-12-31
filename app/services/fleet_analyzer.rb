class FleetAnalyzer
  def initialize(project_id)
    @project_id = project_id
  end

  def overview
    hosts = Host.for_project(@project_id)

    {
      total_hosts: hosts.count,
      online: hosts.where(status: "online").count,
      offline: hosts.where(status: "offline").count,
      warning: hosts.where(status: "warning").count,
      critical: hosts.where(status: "critical").count,

      by_environment: hosts.group(:environment).count,
      by_role: hosts.group(:role).count,
      by_cloud: hosts.group(:cloud_provider).count,

      resources: aggregate_resources(hosts),
      top_cpu: top_by_metric(hosts, :cpu_usage_percent),
      top_memory: top_by_metric(hosts, :memory_usage_percent)
    }
  end

  def capacity_summary
    hosts = Host.for_project(@project_id).where(status: "online")

    {
      total_cpu_cores: hosts.sum(:cpu_cores),
      total_memory_gb: (hosts.sum(:memory_total_bytes).to_f / 1.gigabyte).round(1),

      avg_cpu_usage: average_metric(hosts, :cpu_usage_percent),
      avg_memory_usage: average_metric(hosts, :memory_usage_percent),

      headroom: calculate_headroom(hosts)
    }
  end

  private

  def aggregate_resources(hosts)
    recent_metrics = HostMetric.joins(:host)
                               .where(hosts: { platform_project_id: @project_id })
                               .where("host_metrics.recorded_at > ?", 5.minutes.ago)

    {
      avg_cpu: recent_metrics.average(:cpu_usage_percent)&.round(1) || 0,
      avg_memory: recent_metrics.average(:memory_usage_percent)&.round(1) || 0,
      avg_load: recent_metrics.average(:load_1m)&.round(2) || 0
    }
  end

  def top_by_metric(hosts, metric, limit: 5)
    hosts.joins(:host_metrics)
         .where("host_metrics.recorded_at > ?", 5.minutes.ago)
         .select("hosts.*, host_metrics.#{metric} as current_value")
         .order("host_metrics.#{metric} DESC")
         .limit(limit)
         .map { |h| { name: h.name, value: h.current_value&.round(1) || 0 } }
  end

  def average_metric(hosts, metric)
    HostMetric.joins(:host)
              .where(hosts: { id: hosts.pluck(:id) })
              .where("host_metrics.recorded_at > ?", 5.minutes.ago)
              .average(metric)
              &.round(1) || 0
  end

  def calculate_headroom(hosts)
    avg_cpu = average_metric(hosts, :cpu_usage_percent)
    avg_memory = average_metric(hosts, :memory_usage_percent)

    {
      cpu_headroom: (100 - avg_cpu).round(1),
      memory_headroom: (100 - avg_memory).round(1),
      can_add_load: avg_cpu < 70 && avg_memory < 70
    }
  end
end
