class ContainerMetric < ApplicationRecord
  belongs_to :container

  scope :recent, -> { where("recorded_at > ?", 1.hour.ago) }

  def self.cpu_series(period: 24.hours, interval: "5 minutes")
    where("recorded_at > ?", period.ago)
      .group("time_bucket('#{interval}', recorded_at)")
      .average(:cpu_usage_percent)
      .transform_values { |v| v&.round(1) }
  end

  def self.memory_series(period: 24.hours, interval: "5 minutes")
    where("recorded_at > ?", period.ago)
      .group("time_bucket('#{interval}', recorded_at)")
      .average(:memory_usage_percent)
      .transform_values { |v| v&.round(1) }
  end

  def memory_used_mb
    (memory_used_bytes.to_f / 1.megabyte).round(1)
  end

  def memory_limit_mb
    (memory_limit_bytes.to_f / 1.megabyte).round(1)
  end
end
