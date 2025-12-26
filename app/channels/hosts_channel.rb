class HostsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "hosts_#{current_project_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
