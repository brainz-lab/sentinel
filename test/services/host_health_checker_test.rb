require "test_helper"

class HostHealthCheckerTest < ActiveSupport::TestCase
  setup do
    @project = create_project
    @host    = create_host(project: @project)
  end

  # ---------------------------------------------------------------------------
  # THRESHOLDS constant
  # ---------------------------------------------------------------------------
  test "THRESHOLDS defines expected keys" do
    %i[cpu_warning cpu_critical memory_warning memory_critical
       disk_warning disk_critical load_warning_multiplier load_critical_multiplier].each do |key|
      assert HostHealthChecker::THRESHOLDS.key?(key), "Missing threshold: #{key}"
    end
  end

  # ---------------------------------------------------------------------------
  # #check — offline host
  # ---------------------------------------------------------------------------
  test "returns offline status when host is not online" do
    @host.update!(last_seen_at: 10.minutes.ago)

    result = HostHealthChecker.new(@host).check
    assert_equal "offline", result[:status]
    assert_equal 1, result[:issues].length
    assert_equal "offline", result[:issues].first[:type]
    assert_equal "critical", result[:issues].first[:severity]
  end

  # ---------------------------------------------------------------------------
  # #check — no metrics
  # ---------------------------------------------------------------------------
  test "returns unknown status when host is online but has no metrics" do
    @host.update!(last_seen_at: 30.seconds.ago)

    result = HostHealthChecker.new(@host).check
    assert_equal "unknown", result[:status]
    assert_empty result[:issues]
  end

  # ---------------------------------------------------------------------------
  # #check — healthy host
  # ---------------------------------------------------------------------------
  test "returns online status when all metrics are below thresholds" do
    @host.update!(last_seen_at: 30.seconds.ago)
    add_host_metrics(cpu: 50, memory: 60)

    result = HostHealthChecker.new(@host).check
    assert_equal "online", result[:status]
    assert_empty result[:issues]
  end

  # ---------------------------------------------------------------------------
  # #check — CPU threshold
  # ---------------------------------------------------------------------------
  test "returns warning when CPU exceeds warning threshold" do
    @host.update!(last_seen_at: 30.seconds.ago)
    add_host_metrics(cpu: 82, memory: 50)

    result = HostHealthChecker.new(@host).check
    assert_equal "warning", result[:status]

    cpu_issue = result[:issues].find { |i| i[:type] == "cpu" }
    assert cpu_issue
    assert_equal "warning", cpu_issue[:severity]
  end

  test "returns critical when CPU exceeds critical threshold" do
    @host.update!(last_seen_at: 30.seconds.ago)
    add_host_metrics(cpu: 96, memory: 50)

    result = HostHealthChecker.new(@host).check
    assert_equal "critical", result[:status]

    cpu_issue = result[:issues].find { |i| i[:type] == "cpu" }
    assert cpu_issue
    assert_equal "critical", cpu_issue[:severity]
  end

  # ---------------------------------------------------------------------------
  # #check — memory threshold
  # ---------------------------------------------------------------------------
  test "returns warning when memory exceeds warning threshold" do
    @host.update!(last_seen_at: 30.seconds.ago)
    add_host_metrics(cpu: 30, memory: 87)

    result = HostHealthChecker.new(@host).check
    assert_equal "warning", result[:status]

    mem_issue = result[:issues].find { |i| i[:type] == "memory" }
    assert mem_issue
    assert_equal "warning", mem_issue[:severity]
  end

  test "returns critical when memory exceeds critical threshold" do
    @host.update!(last_seen_at: 30.seconds.ago)
    add_host_metrics(cpu: 30, memory: 96)

    result = HostHealthChecker.new(@host).check
    assert_equal "critical", result[:status]
  end

  # ---------------------------------------------------------------------------
  # #check — multiple issues
  # ---------------------------------------------------------------------------
  test "returns critical overall when both CPU and memory are critical" do
    @host.update!(last_seen_at: 30.seconds.ago)
    add_host_metrics(cpu: 97, memory: 97)

    result = HostHealthChecker.new(@host).check
    assert_equal "critical", result[:status]
    assert result[:issues].length >= 2
  end

  private

  def create_host(project:)
    project_rec = Project.find_or_create_from_platform(
      platform_project_id: project.platform_project_id,
      name: project.name
    )
    Host.create!(
      project: project_rec,
      platform_project_id: project.platform_project_id,
      name: "health-host",
      hostname: "health-server",
      agent_id: SecureRandom.uuid,
      status: "unknown"
    )
  end

  def add_host_metrics(cpu:, memory:, load: 0.5)
    @host.host_metrics.create!(
      recorded_at: Time.current,
      cpu_usage_percent: cpu,
      memory_usage_percent: memory,
      load_1m: load
    )
  end
end
