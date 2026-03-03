require "test_helper"

class AlertRuleTest < ActiveSupport::TestCase
  setup do
    @project = create_project
    @project_rec = Project.find_or_create_from_platform(
      platform_project_id: @project.platform_project_id,
      name: @project.name
    )
    @rule = build_rule
    @rule.save!
  end

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  test "is valid with required attributes" do
    assert @rule.valid?
  end

  test "requires name" do
    @rule.name = ""
    assert_not @rule.valid?
    assert_includes @rule.errors[:name], "can't be blank"
  end

  test "requires metric" do
    @rule.metric = ""
    assert_not @rule.valid?
    assert_includes @rule.errors[:metric], "can't be blank"
  end

  test "requires operator" do
    @rule.operator = ""
    assert_not @rule.valid?
    assert_includes @rule.errors[:operator], "can't be blank"
  end

  test "requires threshold" do
    @rule.threshold = nil
    assert_not @rule.valid?
    assert_includes @rule.errors[:threshold], "can't be blank"
  end

  test "threshold must be numeric" do
    @rule.threshold = "not_a_number"
    assert_not @rule.valid?
  end

  # ---------------------------------------------------------------------------
  # Scopes
  # ---------------------------------------------------------------------------
  test "enabled scope returns only enabled rules" do
    disabled = build_rule(name: "Disabled", enabled: false)
    disabled.save!

    assert_includes AlertRule.enabled, @rule
    assert_not_includes AlertRule.enabled, disabled
  end

  test "for_project returns rules matching platform_project_id" do
    other_project = create_project
    other_rec = Project.find_or_create_from_platform(
      platform_project_id: other_project.platform_project_id,
      name: other_project.name
    )
    other_rule = AlertRule.create!(
      project: other_rec,
      platform_project_id: other_project.platform_project_id,
      name: "Other Rule", metric: "cpu_usage",
      operator: "gt", threshold: 90, scope_type: "all"
    )

    results = AlertRule.for_project(@project.platform_project_id)
    assert_includes results, @rule
    assert_not_includes results, other_rule
  end

  # ---------------------------------------------------------------------------
  # METRICS / OPERATORS / SEVERITIES constants
  # ---------------------------------------------------------------------------
  test "METRICS includes cpu_usage and memory_usage" do
    assert_includes AlertRule::METRICS, "cpu_usage"
    assert_includes AlertRule::METRICS, "memory_usage"
  end

  test "OPERATORS includes gt, gte, lt, lte, eq" do
    %w[gt gte lt lte eq].each do |op|
      assert_includes AlertRule::OPERATORS, op
    end
  end

  test "SEVERITIES includes info, warning, critical" do
    %w[info warning critical].each do |sev|
      assert_includes AlertRule::SEVERITIES, sev
    end
  end

  # ---------------------------------------------------------------------------
  # #hosts_in_scope
  # ---------------------------------------------------------------------------
  test "hosts_in_scope returns all project hosts for scope_type 'all'" do
    host = create_host
    @rule.update!(scope_type: "all")
    assert_includes @rule.hosts_in_scope, host
  end

  test "hosts_in_scope returns empty for unknown scope_type" do
    @rule.update!(scope_type: "unknown_type")
    assert_empty @rule.hosts_in_scope
  end

  # ---------------------------------------------------------------------------
  # #check_threshold (via evaluate_for_host side-effects)
  # ---------------------------------------------------------------------------
  test "check_threshold gt triggers when value exceeds threshold" do
    @rule.update!(operator: "gt", threshold: 80)
    # Access private method for direct testing
    assert @rule.send(:check_threshold, 85)
    assert_not @rule.send(:check_threshold, 80)
    assert_not @rule.send(:check_threshold, 75)
  end

  test "check_threshold gte triggers when value >= threshold" do
    @rule.update!(operator: "gte", threshold: 80)
    assert @rule.send(:check_threshold, 80)
    assert @rule.send(:check_threshold, 81)
    assert_not @rule.send(:check_threshold, 79)
  end

  test "check_threshold lt triggers when value < threshold" do
    @rule.update!(operator: "lt", threshold: 10)
    assert @rule.send(:check_threshold, 9)
    assert_not @rule.send(:check_threshold, 10)
  end

  test "check_threshold eq triggers when value equals threshold" do
    @rule.update!(operator: "eq", threshold: 50)
    assert @rule.send(:check_threshold, 50)
    assert_not @rule.send(:check_threshold, 51)
  end

  private

  def create_host(**attrs)
    Host.create!(
      project: @project_rec,
      platform_project_id: @project.platform_project_id,
      name: "host-#{SecureRandom.hex(4)}",
      hostname: "server-#{SecureRandom.hex(4)}",
      agent_id: SecureRandom.uuid,
      last_seen_at: Time.current,
      **attrs
    )
  end

  def build_rule(name: "High CPU", enabled: true, **attrs)
    AlertRule.new(
      project: @project_rec,
      platform_project_id: @project.platform_project_id,
      name: name,
      metric: "cpu_usage",
      operator: "gt",
      threshold: 90,
      scope_type: "all",
      severity: "warning",
      aggregation: "avg",
      duration_seconds: 300,
      enabled: enabled,
      currently_firing_hosts: [],
      **attrs
    )
  end
end
