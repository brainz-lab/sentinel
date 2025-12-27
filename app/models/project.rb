class Project < ApplicationRecord
  has_many :hosts, dependent: :destroy
  has_many :host_groups, dependent: :destroy
  has_many :alert_rules, dependent: :destroy

  validates :platform_project_id, presence: true, uniqueness: true
  validates :name, presence: true

  before_validation :generate_platform_project_id, on: :create
  before_validation :generate_slug, on: :create

  scope :by_platform_id, ->(id) { find_by(platform_project_id: id) }

  def self.find_or_create_from_platform(platform_project_id:, name:, slug: nil, environment: 'production')
    find_or_create_by(platform_project_id: platform_project_id) do |project|
      project.name = name
      project.slug = slug || name.parameterize
      project.environment = environment
    end
  end

  def host_count
    hosts.count
  end

  def online_host_count
    hosts.where('last_seen_at > ?', 2.minutes.ago).count
  end

  def offline_host_count
    host_count - online_host_count
  end

  def alert_rule_count
    alert_rules.enabled.count
  end

  private

  def generate_platform_project_id
    self.platform_project_id = SecureRandom.uuid if platform_project_id.blank?
  end

  def generate_slug
    self.slug ||= name&.parameterize
  end
end
