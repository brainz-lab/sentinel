class CheckHostHealthJob < ApplicationJob
  queue_as :default

  def perform(project_id = nil)
    if project_id
      check_hosts_for_project(project_id)
    else
      # Check all projects
      Host.distinct.pluck(:platform_project_id).each do |pid|
        check_hosts_for_project(pid)
      end
    end
  end

  private

  def check_hosts_for_project(project_id)
    hosts = Host.for_project(project_id)

    # Mark stale hosts as offline
    hosts.stale.where.not(status: 'offline').find_each do |host|
      host.update!(status: 'offline')
      broadcast_status_change(host)
    end

    # Check health of online hosts
    hosts.where.not(status: 'offline').find_each do |host|
      result = HostHealthChecker.new(host).check
      if host.status != result[:status]
        host.update!(status: result[:status])
        broadcast_status_change(host)
      end
    end

    # Evaluate alert rules
    AlertRule.for_project(project_id).enabled.find_each(&:evaluate_all)
  end

  def broadcast_status_change(host)
    ActionCable.server.broadcast(
      "hosts_#{host.platform_project_id}",
      {
        type: 'status_change',
        host_id: host.id,
        name: host.name,
        status: host.status,
        updated_at: Time.current
      }
    )
  end
end
