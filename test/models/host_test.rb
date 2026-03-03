require "test_helper"

class HostTest < ActiveSupport::TestCase
  setup do
    @project = create_project
    @host    = create_host(project: @project)
  end

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  test "is valid with required attributes" do
    assert @host.valid?
  end

  test "requires name" do
    @host.name = ""
    assert_not @host.valid?
    assert_includes @host.errors[:name], "can't be blank"
  end

  test "requires hostname" do
    @host.hostname = ""
    assert_not @host.valid?
    assert_includes @host.errors[:hostname], "can't be blank"
  end

  test "requires agent_id" do
    @host.agent_id = ""
    assert_not @host.valid?
    assert_includes @host.errors[:agent_id], "can't be blank"
  end

  test "agent_id must be unique within a project" do
    duplicate = Host.new(
      project: @project,
      name: "dup",
      hostname: "dup",
      agent_id: @host.agent_id,
      platform_project_id: @project.platform_project_id
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:agent_id], "has already been taken"
  end

  # ---------------------------------------------------------------------------
  # Scopes
  # ---------------------------------------------------------------------------
  test "for_project returns hosts matching platform_project_id" do
    other_project = create_project
    other_host    = create_host(project: other_project, platform_project_id: "other_project")

    results = Host.for_project(@project.platform_project_id)
    assert_includes results, @host
    assert_not_includes results, other_host
  end

  test "online scope returns only online hosts" do
    @host.update!(status: "online")
    offline = create_host(project: @project, status: "offline")

    assert_includes Host.where(status: "online"), @host
    assert_not_includes Host.where(status: "online"), offline
  end

  test "with_issues scope includes warning and critical" do
    @host.update!(status: "warning")
    critical = create_host(project: @project, status: "critical")
    online   = create_host(project: @project, status: "online")

    issues = Host.with_issues
    assert_includes issues, @host
    assert_includes issues, critical
    assert_not_includes issues, online
  end

  # ---------------------------------------------------------------------------
  # #online?
  # ---------------------------------------------------------------------------
  test "online? returns true when last_seen_at is within 2 minutes" do
    @host.update!(last_seen_at: 1.minute.ago)
    assert @host.online?
  end

  test "online? returns false when last_seen_at is older than 2 minutes" do
    @host.update!(last_seen_at: 3.minutes.ago)
    assert_not @host.online?
  end

  test "online? returns false when last_seen_at is nil" do
    @host.update_column(:last_seen_at, nil)
    assert_not @host.online?
  end

  # ---------------------------------------------------------------------------
  # #current_cpu / #current_memory / #current_load
  # ---------------------------------------------------------------------------
  test "current_cpu returns 0 when no metrics" do
    assert_equal 0, @host.current_cpu
  end

  test "current_memory returns 0 when no metrics" do
    assert_equal 0, @host.current_memory
  end

  test "current_load returns 0 when no metrics" do
    assert_equal 0, @host.current_load
  end

  # ---------------------------------------------------------------------------
  # #memory_total_gb
  # ---------------------------------------------------------------------------
  test "memory_total_gb converts bytes to GB correctly" do
    @host.update!(memory_total_bytes: 8.gigabytes)
    assert_equal 8.0, @host.memory_total_gb
  end

  test "memory_total_gb returns 0.0 when nil" do
    @host.update_column(:memory_total_bytes, nil)
    assert_equal 0.0, @host.memory_total_gb
  end

  # ---------------------------------------------------------------------------
  # #update_status!
  # ---------------------------------------------------------------------------
  test "update_status! sets offline when host is not online" do
    @host.update!(last_seen_at: 10.minutes.ago, status: "online")
    @host.update_status!
    assert_equal "offline", @host.reload.status
  end

  test "update_status! does not update when status unchanged" do
    @host.update!(last_seen_at: 10.minutes.ago, status: "offline")
    original_updated_at = @host.updated_at
    sleep(0.01)
    @host.update_status!
    assert_equal original_updated_at.to_i, @host.reload.updated_at.to_i
  end

  # ---------------------------------------------------------------------------
  # Enum
  # ---------------------------------------------------------------------------
  test "status enum has expected values" do
    assert Host.statuses.keys.include?("unknown")
    assert Host.statuses.keys.include?("online")
    assert Host.statuses.keys.include?("offline")
    assert Host.statuses.keys.include?("warning")
    assert Host.statuses.keys.include?("critical")
  end

  private

  def create_host(project:, platform_project_id: nil, status: "unknown", **attrs)
    Host.create!(
      project: project,
      platform_project_id: platform_project_id || project.platform_project_id,
      name: "host-#{SecureRandom.hex(4)}",
      hostname: "server-#{SecureRandom.hex(4)}",
      agent_id: SecureRandom.uuid,
      status: status,
      last_seen_at: Time.current,
      **attrs
    )
  end
end
