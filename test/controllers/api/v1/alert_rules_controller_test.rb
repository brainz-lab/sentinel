require "test_helper"

class Api::V1::AlertRulesControllerTest < ActionDispatch::IntegrationTest
  MASTER_KEY = ENV.fetch("SENTINEL_MASTER_KEY", "bl_sentinel_master_dev_key_12345")
  PROJECT_ID  = "development"

  setup do
    @rule = AlertRule.create!(
      platform_project_id: PROJECT_ID,
      project: dev_project,
      name: "High CPU",
      metric: "cpu_usage",
      operator: "gt",
      threshold: 90,
      scope_type: "all",
      severity: "warning",
      aggregation: "avg",
      duration_seconds: 300,
      enabled: true,
      currently_firing_hosts: []
    )
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/alert_rules
  # ---------------------------------------------------------------------------
  test "GET index returns 200 with alert rules" do
    get "/api/v1/alert_rules", headers: auth_headers, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json["alert_rules"].is_a?(Array)
    assert json["alert_rules"].length >= 1
  end

  test "GET index returns 401 without authentication" do
    get "/api/v1/alert_rules", as: :json
    assert_response :unauthorized
  end

  test "GET index filters by enabled=true" do
    disabled = AlertRule.create!(
      platform_project_id: PROJECT_ID, project: dev_project,
      name: "Disabled Rule", metric: "memory_usage",
      operator: "gt", threshold: 95, scope_type: "all",
      enabled: false, currently_firing_hosts: []
    )

    get "/api/v1/alert_rules", params: { enabled: "true" }, headers: auth_headers, as: :json

    json = JSON.parse(response.body)
    names = json["alert_rules"].map { |r| r["name"] }
    assert_includes names, "High CPU"
    assert_not_includes names, "Disabled Rule"
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/alert_rules/:id
  # ---------------------------------------------------------------------------
  test "GET show returns alert rule details" do
    get "/api/v1/alert_rules/#{@rule.id}", headers: auth_headers, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @rule.id, json["alert_rule"]["id"]
    assert_equal "High CPU", json["alert_rule"]["name"]
    assert json["alert_rule"].key?("scope_type")
    assert json["alert_rule"].key?("aggregation")
  end

  test "GET show returns 404 for unknown rule" do
    get "/api/v1/alert_rules/#{SecureRandom.uuid}", headers: auth_headers, as: :json
    assert_response :not_found
  end

  # ---------------------------------------------------------------------------
  # POST /api/v1/alert_rules
  # ---------------------------------------------------------------------------
  test "POST create creates a new alert rule" do
    assert_difference "AlertRule.count", 1 do
      post "/api/v1/alert_rules",
        params: { alert_rule: {
          name: "High Memory",
          metric: "memory_usage",
          operator: "gt",
          threshold: 90,
          scope_type: "all",
          severity: "critical"
        }},
        headers: auth_headers, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "High Memory", json["alert_rule"]["name"]
  end

  test "POST create returns 401 without authentication" do
    post "/api/v1/alert_rules",
      params: { alert_rule: { name: "Test", metric: "cpu_usage" } },
      as: :json
    assert_response :unauthorized
  end

  # ---------------------------------------------------------------------------
  # PATCH /api/v1/alert_rules/:id
  # ---------------------------------------------------------------------------
  test "PATCH update modifies the alert rule" do
    patch "/api/v1/alert_rules/#{@rule.id}",
      params: { alert_rule: { threshold: 95, severity: "critical" } },
      headers: auth_headers, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 95, json["alert_rule"]["threshold"]
    assert_equal "critical", json["alert_rule"]["severity"]
  end

  # ---------------------------------------------------------------------------
  # DELETE /api/v1/alert_rules/:id
  # ---------------------------------------------------------------------------
  test "DELETE destroy removes the alert rule" do
    assert_difference "AlertRule.count", -1 do
      delete "/api/v1/alert_rules/#{@rule.id}", headers: auth_headers, as: :json
    end
    assert_response :no_content
  end

  # ---------------------------------------------------------------------------
  # POST /api/v1/alert_rules/:id/enable
  # ---------------------------------------------------------------------------
  test "POST enable activates a disabled rule" do
    @rule.update!(enabled: false)

    post "/api/v1/alert_rules/#{@rule.id}/enable", headers: auth_headers, as: :json

    assert_response :success
    assert @rule.reload.enabled
  end

  # ---------------------------------------------------------------------------
  # POST /api/v1/alert_rules/:id/disable
  # ---------------------------------------------------------------------------
  test "POST disable deactivates an enabled rule" do
    post "/api/v1/alert_rules/#{@rule.id}/disable", headers: auth_headers, as: :json

    assert_response :success
    assert_not @rule.reload.enabled
  end

  private

  def auth_headers
    { "Authorization" => "Bearer #{MASTER_KEY}", "Content-Type" => "application/json" }
  end

  def dev_project
    @dev_project ||= Project.find_or_create_from_platform(
      platform_project_id: PROJECT_ID,
      name: "Development"
    )
  end
end
