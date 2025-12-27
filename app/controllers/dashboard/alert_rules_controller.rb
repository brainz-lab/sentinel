module Dashboard
  class AlertRulesController < BaseController
    before_action :require_project!
    before_action :set_alert_rule, only: [:show, :edit, :update, :destroy]

    def index
      @alert_rules = current_project.alert_rules.order(created_at: :desc)
    end

    def show
      @firing_hosts = Host.where(id: @alert_rule.currently_firing_hosts)
    end

    def new
      @alert_rule = current_project.alert_rules.build(
        scope_type: 'all',
        operator: 'gt',
        severity: 'warning',
        duration_seconds: 300
      )
      @host_groups = current_project.host_groups
      @hosts = current_project.hosts
    end

    def create
      @alert_rule = current_project.alert_rules.build(alert_rule_params)
      if @alert_rule.save
        redirect_to dashboard_project_alert_rule_path(current_project, @alert_rule), notice: "Alert rule created successfully"
      else
        @host_groups = current_project.host_groups
        @hosts = current_project.hosts
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @host_groups = current_project.host_groups
      @hosts = current_project.hosts
    end

    def update
      if @alert_rule.update(alert_rule_params)
        redirect_to dashboard_project_alert_rule_path(current_project, @alert_rule), notice: "Alert rule updated successfully"
      else
        @host_groups = current_project.host_groups
        @hosts = current_project.hosts
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @alert_rule.destroy
      redirect_to dashboard_project_alert_rules_path(current_project), notice: "Alert rule deleted successfully"
    end

    private

    def set_alert_rule
      @alert_rule = current_project.alert_rules.find(params[:id])
    end

    def alert_rule_params
      params.require(:alert_rule).permit(
        :name, :metric, :operator, :threshold, :duration_seconds,
        :severity, :enabled, :scope_type, :scope_group_id, :scope_host_id,
        :aggregation, :mount_point, :interface, scope_tags: {}
      )
    end
  end
end
