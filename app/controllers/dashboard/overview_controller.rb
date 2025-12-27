module Dashboard
  class OverviewController < BaseController
    before_action :require_project!

    def index
      @hosts = current_project.hosts.includes(:host_group).order(created_at: :desc).limit(20)
      @host_count = current_project.host_count
      @online_count = current_project.online_host_count
      @offline_count = current_project.offline_host_count
      @alert_count = current_project.alert_rule_count
      @host_groups = current_project.host_groups.includes(:hosts).limit(5)
    end
  end
end
