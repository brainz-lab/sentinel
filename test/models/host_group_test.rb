require "test_helper"

class HostGroupTest < ActiveSupport::TestCase
  setup do
    @project = create_project
    @group   = HostGroup.create!(
      project: project_record,
      platform_project_id: @project.platform_project_id,
      name: "Web Servers"
    )
  end

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  test "is valid with required attributes" do
    assert @group.valid?
  end

  test "requires name" do
    @group.name = ""
    assert_not @group.valid?
    assert_includes @group.errors[:name], "can't be blank"
  end

  test "name must be unique within a project" do
    duplicate = HostGroup.new(
      project: project_record,
      platform_project_id: @project.platform_project_id,
      name: "Web Servers"
    )
    assert_not duplicate.valid?
  end

  test "for_project returns groups for the given platform_project_id" do
    other_project = create_project
    other_rec = Project.find_or_create_from_platform(
      platform_project_id: other_project.platform_project_id,
      name: other_project.name
    )
    other_group = HostGroup.create!(
      project: other_rec,
      platform_project_id: other_project.platform_project_id,
      name: "DB Servers"
    )

    results = HostGroup.for_project(@project.platform_project_id)
    assert_includes results, @group
    assert_not_includes results, other_group
  end

  # ---------------------------------------------------------------------------
  # #matches?
  # ---------------------------------------------------------------------------
  test "matches? returns true when no auto_assign_rules" do
    host = build_host
    assert @group.matches?(host)
  end

  test "matches? returns true when all rules match" do
    @group.update!(auto_assign_rules: [
      { "field" => "environment", "operator" => "eq", "value" => "production" }
    ])
    host = build_host(environment: "production")
    assert @group.matches?(host)
  end

  test "matches? returns false when any rule does not match" do
    @group.update!(auto_assign_rules: [
      { "field" => "environment", "operator" => "eq", "value" => "production" }
    ])
    host = build_host(environment: "staging")
    assert_not @group.matches?(host)
  end

  test "matches? supports contains operator" do
    @group.update!(auto_assign_rules: [
      { "field" => "name", "operator" => "contains", "value" => "web" }
    ])
    host = build_host(name: "web-01")
    assert @group.matches?(host)
  end

  test "matches? supports starts_with operator" do
    @group.update!(auto_assign_rules: [
      { "field" => "name", "operator" => "starts_with", "value" => "app-" }
    ])
    host = build_host(name: "app-01")
    assert @group.matches?(host)
  end

  test "matches? supports neq operator" do
    @group.update!(auto_assign_rules: [
      { "field" => "environment", "operator" => "neq", "value" => "production" }
    ])
    host = build_host(environment: "staging")
    assert @group.matches?(host)
  end

  test "matches? supports tag field lookup" do
    @group.update!(auto_assign_rules: [
      { "field" => "tags.tier", "operator" => "eq", "value" => "frontend" }
    ])
    host = build_host(tags: { "tier" => "frontend" })
    assert @group.matches?(host)
  end

  # ---------------------------------------------------------------------------
  # #host_count
  # ---------------------------------------------------------------------------
  test "host_count returns 0 with no hosts" do
    assert_equal 0, @group.host_count
  end

  private

  def project_record
    @project_record ||= Project.find_or_create_from_platform(
      platform_project_id: @project.platform_project_id,
      name: @project.name
    )
  end

  def build_host(name: "test-host", environment: "production", tags: {}, **attrs)
    Host.new(
      project: project_record,
      platform_project_id: @project.platform_project_id,
      name: name,
      hostname: name,
      agent_id: SecureRandom.uuid,
      environment: environment,
      tags: tags,
      **attrs
    )
  end
end
