require "test_helper"

class MetricIngesterTest < ActiveSupport::TestCase
  setup do
    @project = create_project
    @project_rec = Project.find_or_create_from_platform(
      platform_project_id: @project.platform_project_id,
      name: @project.name
    )
    @host = Host.create!(
      project: @project_rec,
      platform_project_id: @project.platform_project_id,
      name: "ingest-host",
      hostname: "ingest-server",
      agent_id: SecureRandom.uuid,
      status: "unknown"
    )
    @ingester = MetricIngester.new(@host)
  end

  # ---------------------------------------------------------------------------
  # #ingest — system metrics
  # ---------------------------------------------------------------------------
  test "ingest creates a HostMetric record" do
    assert_difference "@host.host_metrics.count", 1 do
      @ingester.ingest(system_payload)
    end
  end

  test "ingest stores cpu_usage_percent correctly" do
    @ingester.ingest(system_payload(cpu_usage: 55.5))
    assert_in_delta 55.5, @host.host_metrics.last.cpu_usage_percent, 0.01
  end

  test "ingest stores memory_usage_percent correctly" do
    @ingester.ingest(system_payload(memory_usage: 72.3))
    assert_in_delta 72.3, @host.host_metrics.last.memory_usage_percent, 0.01
  end

  test "ingest updates host last_seen_at" do
    freeze_time = Time.current
    travel_to freeze_time do
      @ingester.ingest(system_payload)
    end
    assert_equal freeze_time.to_i, @host.reload.last_seen_at.to_i
  end

  # ---------------------------------------------------------------------------
  # #ingest — disk metrics
  # ---------------------------------------------------------------------------
  test "ingest creates DiskMetric records" do
    payload = system_payload.merge(
      disks: [
        { device: "/dev/sda1", mount_point: "/", filesystem: "ext4",
          total: 100.gigabytes, used: 40.gigabytes, free: 60.gigabytes,
          usage_percent: 40.0 }
      ]
    )

    assert_difference "@host.disk_metrics.count", 1 do
      @ingester.ingest(payload)
    end

    disk = @host.disk_metrics.last
    assert_equal "/", disk.mount_point
    assert_in_delta 40.0, disk.usage_percent, 0.01
  end

  # ---------------------------------------------------------------------------
  # #ingest — network metrics
  # ---------------------------------------------------------------------------
  test "ingest creates NetworkMetric records" do
    payload = system_payload.merge(
      network: [
        { name: "eth0", bytes_sent: 1024, bytes_received: 2048,
          packets_sent: 10, packets_received: 20,
          errors_in: 0, errors_out: 0 }
      ]
    )

    assert_difference "@host.network_metrics.count", 1 do
      @ingester.ingest(payload)
    end

    net = @host.network_metrics.last
    assert_equal "eth0", net.interface
    assert_equal 1024, net.bytes_sent
  end

  # ---------------------------------------------------------------------------
  # #ingest — process snapshots
  # ---------------------------------------------------------------------------
  test "ingest creates ProcessSnapshot records" do
    payload = system_payload.merge(
      processes: [
        { pid: 1234, ppid: 1, name: "ruby", command: "ruby app.rb",
          user: "deploy", state: "R",
          cpu_percent: 12.5, memory_percent: 3.2, memory_rss: 50.megabytes }
      ]
    )

    assert_difference "@host.process_snapshots.count", 1 do
      @ingester.ingest(payload)
    end

    snap = @host.process_snapshots.last
    assert_equal "ruby", snap.name
    assert_equal 1234, snap.pid
  end

  # ---------------------------------------------------------------------------
  # #ingest — handles nil sections gracefully
  # ---------------------------------------------------------------------------
  test "ingest skips nil system section without error" do
    assert_nothing_raised do
      @ingester.ingest({ disks: nil, network: nil })
    end
  end

  test "ingest skips nil disks section without error" do
    assert_nothing_raised do
      @ingester.ingest(system_payload.merge(disks: nil))
    end
  end

  private

  def system_payload(cpu_usage: 45.0, memory_usage: 60.0)
    {
      system: {
        cpu_usage: cpu_usage,
        cpu_user: cpu_usage * 0.7,
        cpu_system: cpu_usage * 0.3,
        cpu_iowait: 1.0,
        cpu_steal: 0.0,
        load_1m: 1.2,
        load_5m: 1.0,
        load_15m: 0.9,
        memory_used: 4.gigabytes,
        memory_free: 2.gigabytes,
        memory_available: 4.gigabytes,
        memory_cached: 1.gigabyte,
        memory_buffers: 512.megabytes,
        memory_usage: memory_usage,
        swap_used: 0,
        swap_free: 2.gigabytes,
        swap_usage: 0.0,
        processes_total: 200,
        processes_running: 5,
        processes_blocked: 0,
        processes_zombie: 0,
        uptime: 86400
      }
    }
  end
end
