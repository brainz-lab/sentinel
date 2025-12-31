module Api
  module V1
    class AlertRulesController < BaseController
      before_action :set_alert_rule, only: [ :show, :update, :destroy, :test, :enable, :disable ]

      # GET /api/v1/alert_rules
      def index
        rules = AlertRule.for_project(@project_id)
        rules = rules.enabled if params[:enabled] == "true"

        render json: {
          alert_rules: rules.map { |r| rule_summary(r) }
        }
      end

      # GET /api/v1/alert_rules/:id
      def show
        render json: {
          alert_rule: rule_details(@alert_rule)
        }
      end

      # POST /api/v1/alert_rules
      def create
        rule = AlertRule.new(alert_rule_params)
        rule.platform_project_id = @project_id

        if rule.save
          render json: { alert_rule: rule_details(rule) }, status: :created
        else
          render json: { errors: rule.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/alert_rules/:id
      def update
        if @alert_rule.update(alert_rule_params)
          render json: { alert_rule: rule_details(@alert_rule) }
        else
          render json: { errors: @alert_rule.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/alert_rules/:id
      def destroy
        @alert_rule.destroy!
        head :no_content
      end

      # POST /api/v1/alert_rules/:id/test
      def test
        results = @alert_rule.hosts_in_scope.map do |host|
          value = @alert_rule.send(:fetch_metric_value, host)
          breached = @alert_rule.send(:check_threshold, value)
          {
            host_id: host.id,
            host_name: host.name,
            current_value: value&.round(2),
            threshold: @alert_rule.threshold,
            would_trigger: breached
          }
        end

        render json: { test_results: results }
      end

      # POST /api/v1/alert_rules/:id/enable
      def enable
        @alert_rule.update!(enabled: true)
        render json: { alert_rule: rule_details(@alert_rule) }
      end

      # POST /api/v1/alert_rules/:id/disable
      def disable
        @alert_rule.update!(enabled: false)
        render json: { alert_rule: rule_details(@alert_rule) }
      end

      private

      def set_alert_rule
        @alert_rule = AlertRule.for_project(@project_id).find(params[:id])
      end

      def alert_rule_params
        params.require(:alert_rule).permit(
          :name, :enabled, :scope_type, :scope_host_id, :scope_group_id,
          :metric, :operator, :threshold, :aggregation, :duration_seconds,
          :mount_point, :interface, :severity,
          scope_tags: {}
        )
      end

      def rule_summary(rule)
        {
          id: rule.id,
          name: rule.name,
          enabled: rule.enabled,
          metric: rule.metric,
          operator: rule.operator,
          threshold: rule.threshold,
          severity: rule.severity,
          firing_count: rule.currently_firing_hosts.length
        }
      end

      def rule_details(rule)
        rule_summary(rule).merge(
          scope_type: rule.scope_type,
          scope_host_id: rule.scope_host_id,
          scope_group_id: rule.scope_group_id,
          scope_tags: rule.scope_tags,
          aggregation: rule.aggregation,
          duration_seconds: rule.duration_seconds,
          mount_point: rule.mount_point,
          interface: rule.interface,
          currently_firing_hosts: rule.currently_firing_hosts,
          last_triggered_at: rule.last_triggered_at&.iso8601,
          last_resolved_at: rule.last_resolved_at&.iso8601,
          created_at: rule.created_at.iso8601,
          updated_at: rule.updated_at.iso8601
        )
      end
    end
  end
end
