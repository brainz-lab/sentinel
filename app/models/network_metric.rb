class NetworkMetric < ApplicationRecord
  belongs_to :host

  scope :recent, -> { where('recorded_at > ?', 1.hour.ago) }

  def self.throughput_series(interface:, period: 24.hours, interval: '5 minutes')
    where(interface: interface)
      .where('recorded_at > ?', period.ago)
      .group("time_bucket('#{interval}', recorded_at)")
      .select(
        "time_bucket('#{interval}', recorded_at) as bucket",
        'SUM(bytes_sent) as total_sent',
        'SUM(bytes_received) as total_received'
      )
  end

  def bytes_sent_mb
    (bytes_sent.to_f / 1.megabyte).round(2)
  end

  def bytes_received_mb
    (bytes_received.to_f / 1.megabyte).round(2)
  end
end
