class HostGroup < ApplicationRecord
  has_many :hosts, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :platform_project_id }
  validates :platform_project_id, presence: true

  scope :for_project, ->(project_id) { where(platform_project_id: project_id) }

  def matches?(host)
    return true if auto_assign_rules.blank?

    auto_assign_rules.all? do |rule|
      value = extract_value(host, rule['field'])
      compare(value, rule['operator'], rule['value'])
    end
  end

  def host_count
    hosts.count
  end

  def average_cpu
    hosts.joins(:host_metrics)
         .where('host_metrics.recorded_at > ?', 5.minutes.ago)
         .average('host_metrics.cpu_usage_percent')
         &.round(1) || 0
  end

  def average_memory
    hosts.joins(:host_metrics)
         .where('host_metrics.recorded_at > ?', 5.minutes.ago)
         .average('host_metrics.memory_usage_percent')
         &.round(1) || 0
  end

  private

  def extract_value(host, field)
    if field.start_with?('tags.')
      tag_key = field.sub('tags.', '')
      host.tags[tag_key]
    else
      host.send(field)
    end
  rescue
    nil
  end

  def compare(value, operator, expected)
    case operator
    when 'eq' then value == expected
    when 'neq' then value != expected
    when 'contains' then value.to_s.include?(expected.to_s)
    when 'starts_with' then value.to_s.start_with?(expected.to_s)
    when 'regex' then value.to_s.match?(Regexp.new(expected))
    else false
    end
  end
end
