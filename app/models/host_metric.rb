class HostMetric < ApplicationRecord
  belongs_to :host

  scope :recent, -> { where('recorded_at > ?', 1.hour.ago) }

  def self.cpu_series(period: 24.hours, interval: '5 minutes')
    where('recorded_at > ?', period.ago)
      .group("time_bucket('#{interval}', recorded_at)")
      .average(:cpu_usage_percent)
      .transform_values { |v| v&.round(1) }
  end

  def self.memory_series(period: 24.hours, interval: '5 minutes')
    where('recorded_at > ?', period.ago)
      .group("time_bucket('#{interval}', recorded_at)")
      .average(:memory_usage_percent)
      .transform_values { |v| v&.round(1) }
  end

  def self.load_series(period: 24.hours, interval: '5 minutes')
    where('recorded_at > ?', period.ago)
      .group("time_bucket('#{interval}', recorded_at)")
      .average(:load_1m)
      .transform_values { |v| v&.round(2) }
  end

  # Fallback for non-TimescaleDB databases
  def self.cpu_series_fallback(period: 24.hours)
    where('recorded_at > ?', period.ago)
      .group_by_minute(:recorded_at, n: 5)
      .average(:cpu_usage_percent)
  end
end
