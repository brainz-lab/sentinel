class HostHealthChecker
  THRESHOLDS = {
    cpu_warning: 80,
    cpu_critical: 95,
    memory_warning: 85,
    memory_critical: 95,
    disk_warning: 80,
    disk_critical: 90,
    load_warning_multiplier: 1.5,
    load_critical_multiplier: 2.0
  }.freeze

  def initialize(host)
    @host = host
  end

  def check
    issues = []

    unless @host.online?
      return {
        status: 'offline',
        issues: [{ type: 'offline', severity: 'critical', message: 'Host is offline' }]
      }
    end

    metrics = @host.latest_metrics
    return { status: 'unknown', issues: [] } unless metrics

    # CPU check
    if metrics.cpu_usage_percent.to_f >= THRESHOLDS[:cpu_critical]
      issues << { type: 'cpu', severity: 'critical', value: metrics.cpu_usage_percent }
    elsif metrics.cpu_usage_percent.to_f >= THRESHOLDS[:cpu_warning]
      issues << { type: 'cpu', severity: 'warning', value: metrics.cpu_usage_percent }
    end

    # Memory check
    if metrics.memory_usage_percent.to_f >= THRESHOLDS[:memory_critical]
      issues << { type: 'memory', severity: 'critical', value: metrics.memory_usage_percent }
    elsif metrics.memory_usage_percent.to_f >= THRESHOLDS[:memory_warning]
      issues << { type: 'memory', severity: 'warning', value: metrics.memory_usage_percent }
    end

    # Load check
    if @host.cpu_cores.present? && @host.cpu_cores > 0
      load_warning = @host.cpu_cores * THRESHOLDS[:load_warning_multiplier]
      load_critical = @host.cpu_cores * THRESHOLDS[:load_critical_multiplier]

      if metrics.load_1m.to_f >= load_critical
        issues << { type: 'load', severity: 'critical', value: metrics.load_1m }
      elsif metrics.load_1m.to_f >= load_warning
        issues << { type: 'load', severity: 'warning', value: metrics.load_1m }
      end
    end

    # Disk check
    @host.disk_usage.each do |disk|
      if disk.usage_percent.to_f >= THRESHOLDS[:disk_critical]
        issues << { type: 'disk', severity: 'critical', mount: disk.mount_point, value: disk.usage_percent }
      elsif disk.usage_percent.to_f >= THRESHOLDS[:disk_warning]
        issues << { type: 'disk', severity: 'warning', mount: disk.mount_point, value: disk.usage_percent }
      end
    end

    # Determine overall status
    status = if issues.any? { |i| i[:severity] == 'critical' }
               'critical'
             elsif issues.any? { |i| i[:severity] == 'warning' }
               'warning'
             else
               'online'
             end

    { status: status, issues: issues }
  end

  def self.check_all_hosts(project_id)
    Host.for_project(project_id).find_each do |host|
      result = new(host).check
      host.update!(status: result[:status]) if host.status != result[:status]
    end
  end
end
