module Dashboard
  class AlertRulesController < BaseController
    before_action :set_alert_rule, only: [:show, :edit, :update, :destroy]

    def index
      @alert_rules = AlertRule.order(created_at: :desc)
    end

    def show
    end

    def new
      @alert_rule = AlertRule.new
    end

    def create
      @alert_rule = AlertRule.new(alert_rule_params)
      if @alert_rule.save
        redirect_to dashboard_alert_rule_path(@alert_rule), notice: "Alert rule created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @alert_rule.update(alert_rule_params)
        redirect_to dashboard_alert_rule_path(@alert_rule), notice: "Alert rule updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @alert_rule.destroy
      redirect_to dashboard_alert_rules_path, notice: "Alert rule deleted successfully"
    end

    private

    def set_alert_rule
      @alert_rule = AlertRule.find(params[:id])
    end

    def alert_rule_params
      params.require(:alert_rule).permit(:name, :description, :metric, :operator, :threshold, :duration_seconds, :severity, :enabled)
    end
  end
end
