module Dashboard
  class OverviewController < BaseController
    def index
      @hosts = Host.includes(:host_group).order(created_at: :desc).limit(20)
      @host_count = Host.count
      @online_count = Host.where("last_seen_at > ?", 2.minutes.ago).count
      @offline_count = @host_count - @online_count
      @alert_count = AlertRule.where(enabled: true).count
    end
  end
end
