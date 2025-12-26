class MetricsChannel < ApplicationCable::Channel
  def subscribed
    host_id = params[:host_id]
    stream_from "host_#{host_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
