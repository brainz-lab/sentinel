class DiskMetric < ApplicationRecord
  belongs_to :host

  scope :recent, -> { where('recorded_at > ?', 1.hour.ago) }

  def self.usage_series(mount_point:, period: 24.hours, interval: '5 minutes')
    where(mount_point: mount_point)
      .where('recorded_at > ?', period.ago)
      .group("time_bucket('#{interval}', recorded_at)")
      .average(:usage_percent)
      .transform_values { |v| v&.round(1) }
  end

  def free_gb
    (free_bytes.to_f / 1.gigabyte).round(1)
  end

  def used_gb
    (used_bytes.to_f / 1.gigabyte).round(1)
  end

  def total_gb
    (total_bytes.to_f / 1.gigabyte).round(1)
  end
end
