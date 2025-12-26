class MetricIngester
  def initialize(host)
    @host = host
  end

  def ingest(payload)
    recorded_at = Time.current

    ActiveRecord::Base.transaction do
      ingest_host_metrics(payload[:system], recorded_at)
      ingest_disk_metrics(payload[:disks], recorded_at)
      ingest_network_metrics(payload[:network], recorded_at)
      ingest_processes(payload[:processes], recorded_at)
      ingest_containers(payload[:containers], recorded_at)

      @host.update!(last_seen_at: recorded_at)
    end

    # Check health and broadcast
    @host.update_status!
    broadcast_update
  end

  private

  def ingest_host_metrics(data, recorded_at)
    return unless data

    @host.host_metrics.create!(
      recorded_at: recorded_at,
      cpu_usage_percent: data[:cpu_usage],
      cpu_user_percent: data[:cpu_user],
      cpu_system_percent: data[:cpu_system],
      cpu_iowait_percent: data[:cpu_iowait],
      cpu_steal_percent: data[:cpu_steal],
      load_1m: data[:load_1m],
      load_5m: data[:load_5m],
      load_15m: data[:load_15m],
      memory_used_bytes: data[:memory_used],
      memory_free_bytes: data[:memory_free],
      memory_available_bytes: data[:memory_available],
      memory_cached_bytes: data[:memory_cached],
      memory_buffers_bytes: data[:memory_buffers],
      memory_usage_percent: data[:memory_usage],
      swap_used_bytes: data[:swap_used],
      swap_free_bytes: data[:swap_free],
      swap_usage_percent: data[:swap_usage],
      processes_total: data[:processes_total],
      processes_running: data[:processes_running],
      processes_blocked: data[:processes_blocked],
      processes_zombie: data[:processes_zombie],
      uptime_seconds: data[:uptime]
    )
  end

  def ingest_disk_metrics(disks, recorded_at)
    return unless disks

    disks.each do |disk|
      @host.disk_metrics.create!(
        recorded_at: recorded_at,
        device: disk[:device],
        mount_point: disk[:mount_point],
        filesystem: disk[:filesystem],
        total_bytes: disk[:total],
        used_bytes: disk[:used],
        free_bytes: disk[:free],
        usage_percent: disk[:usage_percent],
        inodes_total: disk[:inodes_total],
        inodes_used: disk[:inodes_used],
        inodes_free: disk[:inodes_free],
        inodes_usage_percent: disk[:inodes_usage_percent],
        read_bytes: disk[:read_bytes],
        write_bytes: disk[:write_bytes],
        read_ops: disk[:read_ops],
        write_ops: disk[:write_ops],
        io_time_percent: disk[:io_time_percent]
      )
    end
  end

  def ingest_network_metrics(interfaces, recorded_at)
    return unless interfaces

    interfaces.each do |iface|
      @host.network_metrics.create!(
        recorded_at: recorded_at,
        interface: iface[:name],
        bytes_sent: iface[:bytes_sent],
        bytes_received: iface[:bytes_received],
        packets_sent: iface[:packets_sent],
        packets_received: iface[:packets_received],
        errors_in: iface[:errors_in],
        errors_out: iface[:errors_out],
        drops_in: iface[:drops_in],
        drops_out: iface[:drops_out],
        tcp_connections: iface[:tcp_connections],
        tcp_established: iface[:tcp_established],
        tcp_time_wait: iface[:tcp_time_wait],
        tcp_close_wait: iface[:tcp_close_wait]
      )
    end
  end

  def ingest_processes(processes, recorded_at)
    return unless processes

    processes.each do |proc|
      @host.process_snapshots.create!(
        recorded_at: recorded_at,
        pid: proc[:pid],
        ppid: proc[:ppid],
        name: proc[:name],
        command: proc[:command]&.truncate(500),
        user: proc[:user],
        state: proc[:state],
        cpu_percent: proc[:cpu_percent],
        memory_percent: proc[:memory_percent],
        memory_rss_bytes: proc[:memory_rss],
        memory_vms_bytes: proc[:memory_vms],
        io_read_bytes: proc[:io_read],
        io_write_bytes: proc[:io_write],
        threads_count: proc[:threads],
        fd_count: proc[:fds],
        cpu_time_ms: proc[:cpu_time],
        started_at: proc[:started_at] ? Time.at(proc[:started_at]) : nil
      )
    end
  end

  def ingest_containers(containers, recorded_at)
    return unless containers

    containers.each do |cont|
      container = @host.containers.find_or_initialize_by(container_id: cont[:id])

      container.assign_attributes(
        name: cont[:name],
        image: cont[:image],
        status: cont[:status],
        started_at: cont[:started_at] ? Time.at(cont[:started_at]) : nil,
        labels: cont[:labels] || {},
        last_seen_at: recorded_at
      )
      container.save!

      if cont[:stats]
        container.container_metrics.create!(
          recorded_at: recorded_at,
          cpu_usage_percent: cont[:stats][:cpu_percent],
          memory_used_bytes: cont[:stats][:memory_used],
          memory_limit_bytes: cont[:stats][:memory_limit],
          memory_usage_percent: cont[:stats][:memory_percent],
          network_rx_bytes: cont[:stats][:network_rx],
          network_tx_bytes: cont[:stats][:network_tx],
          block_read_bytes: cont[:stats][:block_read],
          block_write_bytes: cont[:stats][:block_write],
          pids_current: cont[:stats][:pids]
        )
      end
    end
  end

  def broadcast_update
    ActionCable.server.broadcast(
      "host_#{@host.id}",
      {
        status: @host.status,
        cpu: @host.current_cpu,
        memory: @host.current_memory,
        load: @host.current_load,
        updated_at: Time.current
      }
    )
  end
end
