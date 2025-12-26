class Container < ApplicationRecord
  belongs_to :host

  has_many :container_metrics, dependent: :delete_all

  validates :container_id, presence: true
  validates :name, presence: true

  scope :running, -> { where(status: 'running') }
  scope :stopped, -> { where(status: 'exited') }
  scope :recent, -> { where('last_seen_at > ?', 5.minutes.ago) }

  def latest_metrics
    container_metrics.order(recorded_at: :desc).first
  end

  def current_cpu
    latest_metrics&.cpu_usage_percent || 0
  end

  def current_memory
    latest_metrics&.memory_usage_percent || 0
  end

  def running?
    status == 'running'
  end

  def uptime
    return nil unless started_at && running?
    Time.current - started_at
  end

  def uptime_humanized
    return 'Not running' unless uptime
    ActiveSupport::Duration.build(uptime.to_i).inspect
  end

  def memory_limit_mb
    return nil unless memory_limit_bytes
    (memory_limit_bytes.to_f / 1.megabyte).round(1)
  end
end
