class AlertRule < ApplicationRecord
  belongs_to :project

  validates :name, presence: true
  validates :metric, presence: true
  validates :operator, presence: true
  validates :threshold, presence: true, numericality: true

  METRICS = %w[
    cpu_usage memory_usage swap_usage load_1m load_5m load_15m
    disk_usage disk_inode_usage
    network_rx_bytes network_tx_bytes network_errors
    process_count
  ].freeze

  OPERATORS = %w[gt gte lt lte eq].freeze
  AGGREGATIONS = %w[avg max min sum].freeze
  SEVERITIES = %w[info warning critical].freeze

  scope :enabled, -> { where(enabled: true) }

  def evaluate_all
    hosts_in_scope.each do |host|
      evaluate_for_host(host)
    end
  end

  def hosts_in_scope
    case scope_type
    when "all"
      project.hosts
    when "group"
      Host.where(host_group_id: scope_group_id)
    when "host"
      Host.where(id: scope_host_id)
    when "tag"
      project.hosts.where("tags @> ?", scope_tags.to_json)
    else
      Host.none
    end
  end

  def evaluate_for_host(host)
    value = fetch_metric_value(host)
    breached = check_threshold(value)

    if breached
      add_firing_host(host) unless firing_for_host?(host)
      maybe_trigger_alert(host, value)
    else
      remove_firing_host(host) if firing_for_host?(host)
      maybe_resolve_alert(host)
    end
  end

  private

  def fetch_metric_value(host)
    case metric
    when "cpu_usage"
      host.host_metrics
          .where("recorded_at > ?", duration_seconds.seconds.ago)
          .send(aggregation, :cpu_usage_percent) || 0
    when "memory_usage"
      host.host_metrics
          .where("recorded_at > ?", duration_seconds.seconds.ago)
          .send(aggregation, :memory_usage_percent) || 0
    when "disk_usage"
      scope = host.disk_metrics.where("recorded_at > ?", duration_seconds.seconds.ago)
      scope = scope.where(mount_point: mount_point) if mount_point.present?
      scope.send(aggregation, :usage_percent) || 0
    when "load_1m"
      host.host_metrics
          .where("recorded_at > ?", duration_seconds.seconds.ago)
          .send(aggregation, :load_1m) || 0
    else
      0
    end
  end

  def check_threshold(value)
    case operator
    when "gt" then value > threshold
    when "gte" then value >= threshold
    when "lt" then value < threshold
    when "lte" then value <= threshold
    when "eq" then value == threshold
    else false
    end
  end

  def firing_for_host?(host)
    currently_firing_hosts.include?(host.id)
  end

  def add_firing_host(host)
    self.currently_firing_hosts = (currently_firing_hosts + [ host.id ]).uniq
    save!
  end

  def remove_firing_host(host)
    self.currently_firing_hosts = currently_firing_hosts - [ host.id ]
    save!
  end

  def maybe_trigger_alert(host, value)
    return if last_triggered_at && last_triggered_at > 5.minutes.ago

    # TODO: Integrate with Signal for alerting
    # Signal::Client.trigger_alert(
    #   source: 'sentinel',
    #   title: "#{name}: #{metric} threshold exceeded on #{host.name}",
    #   message: "Current: #{value.round(1)}, Threshold: #{operator} #{threshold}",
    #   severity: severity,
    #   data: {
    #     host_id: host.id,
    #     host_name: host.name,
    #     metric: metric,
    #     value: value,
    #     threshold: threshold
    #   }
    # )

    update!(last_triggered_at: Time.current)
  end

  def maybe_resolve_alert(host)
    return unless last_triggered_at && !last_resolved_at
    return if currently_firing_hosts.any?

    # TODO: Integrate with Signal for alerting
    # Signal::Client.resolve_alert(
    #   source: 'sentinel',
    #   title: "#{name}: resolved"
    # )

    update!(last_resolved_at: Time.current)
  end
end
