class Host < ApplicationRecord
  belongs_to :host_group, optional: true

  has_many :host_metrics, dependent: :delete_all
  has_many :disk_metrics, dependent: :delete_all
  has_many :network_metrics, dependent: :delete_all
  has_many :process_snapshots, dependent: :delete_all
  has_many :containers, dependent: :destroy

  validates :name, presence: true
  validates :hostname, presence: true
  validates :agent_id, presence: true, uniqueness: { scope: :platform_project_id }
  validates :platform_project_id, presence: true

  enum :status, {
    unknown: 'unknown',
    online: 'online',
    offline: 'offline',
    warning: 'warning',
    critical: 'critical'
  }, prefix: true

  scope :online, -> { where(status: 'online') }
  scope :with_issues, -> { where(status: %w[warning critical]) }
  scope :by_environment, ->(env) { where(environment: env) }
  scope :by_role, ->(role) { where(role: role) }
  scope :stale, -> { where('last_seen_at < ?', 5.minutes.ago) }
  scope :for_project, ->(project_id) { where(platform_project_id: project_id) }

  after_save :auto_assign_group, if: :saved_change_to_tags?

  def online?
    last_seen_at.present? && last_seen_at > 2.minutes.ago
  end

  def latest_metrics
    host_metrics.order(recorded_at: :desc).first
  end

  def current_cpu
    latest_metrics&.cpu_usage_percent || 0
  end

  def current_memory
    latest_metrics&.memory_usage_percent || 0
  end

  def current_load
    latest_metrics&.load_1m || 0
  end

  def disk_usage
    disk_metrics
      .where('recorded_at > ?', 5.minutes.ago)
      .select('DISTINCT ON (mount_point) *')
      .order(:mount_point, recorded_at: :desc)
  end

  def network_usage
    network_metrics
      .where('recorded_at > ?', 5.minutes.ago)
      .select('DISTINCT ON (interface) *')
      .order(:interface, recorded_at: :desc)
  end

  def top_processes(limit: 10)
    process_snapshots
      .where('recorded_at > ?', 2.minutes.ago)
      .order(cpu_percent: :desc)
      .limit(limit)
  end

  def memory_total_gb
    (memory_total_bytes.to_f / 1.gigabyte).round(1)
  end

  def uptime_humanized
    return 'Unknown' unless latest_metrics&.uptime_seconds

    ActiveSupport::Duration.build(latest_metrics.uptime_seconds).inspect
  end

  def update_status!
    new_status = calculate_status
    update!(status: new_status) if status != new_status
  end

  private

  def calculate_status
    return 'offline' unless online?

    metrics = latest_metrics
    return 'unknown' unless metrics

    if metrics.cpu_usage_percent.to_f > 95 || metrics.memory_usage_percent.to_f > 95
      'critical'
    elsif metrics.cpu_usage_percent.to_f > 80 || metrics.memory_usage_percent.to_f > 85
      'warning'
    else
      'online'
    end
  end

  def auto_assign_group
    HostGroup.where(platform_project_id: platform_project_id).find_each do |group|
      if group.matches?(self)
        update_column(:host_group_id, group.id)
        return
      end
    end
  end
end
