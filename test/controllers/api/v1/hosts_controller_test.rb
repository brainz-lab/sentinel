require "test_helper"

class Api::V1::HostsControllerTest < ActionDispatch::IntegrationTest
  MASTER_KEY = ENV.fetch("SENTINEL_MASTER_KEY", "bl_sentinel_master_dev_key_12345")
  PROJECT_ID  = "development"

  setup do
    @host = Host.create!(
      platform_project_id: PROJECT_ID,
      project: dev_project,
      name: "web-01",
      hostname: "web-01.example.com",
      agent_id: SecureRandom.uuid,
      status: "online",
      last_seen_at: 30.seconds.ago
    )
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/hosts
  # ---------------------------------------------------------------------------
  test "GET index returns 200 with host list" do
    get "/api/v1/hosts", headers: auth_headers, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json["hosts"].is_a?(Array)
    assert json["hosts"].length >= 1
    assert json["total"] >= 1
  end

  test "GET index returns 401 without authentication" do
    get "/api/v1/hosts", as: :json
    assert_response :unauthorized
  end

  test "GET index filters by status" do
    offline_host = Host.create!(
      platform_project_id: PROJECT_ID, project: dev_project,
      name: "db-01", hostname: "db-01.example.com",
      agent_id: SecureRandom.uuid, status: "offline"
    )

    get "/api/v1/hosts", params: { status: "online" }, headers: auth_headers, as: :json

    json = JSON.parse(response.body)
    names = json["hosts"].map { |h| h["name"] }
    assert_includes names, "web-01"
    assert_not_includes names, "db-01"
  end

  test "GET index filters by environment" do
    staging_host = Host.create!(
      platform_project_id: PROJECT_ID, project: dev_project,
      name: "stg-01", hostname: "stg-01.example.com",
      agent_id: SecureRandom.uuid, environment: "staging"
    )

    get "/api/v1/hosts", params: { environment: "staging" }, headers: auth_headers, as: :json

    json = JSON.parse(response.body)
    names = json["hosts"].map { |h| h["name"] }
    assert_includes names, "stg-01"
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/hosts/:id
  # ---------------------------------------------------------------------------
  test "GET show returns host details" do
    get "/api/v1/hosts/#{@host.id}", headers: auth_headers, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @host.id, json["host"]["id"]
    assert_equal @host.name, json["host"]["name"]
    assert json["host"].key?("system")
    assert json["host"].key?("current_metrics")
  end

  test "GET show returns 404 for unknown host" do
    get "/api/v1/hosts/#{SecureRandom.uuid}", headers: auth_headers, as: :json
    assert_response :not_found
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/hosts/:id/health
  # ---------------------------------------------------------------------------
  test "GET health returns health check result" do
    get "/api/v1/hosts/#{@host.id}/health", headers: auth_headers, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("status")
    assert json.key?("issues")
  end

  # ---------------------------------------------------------------------------
  # PATCH /api/v1/hosts/:id
  # ---------------------------------------------------------------------------
  test "PATCH update changes host attributes" do
    patch "/api/v1/hosts/#{@host.id}",
      params: { host: { name: "web-01-renamed", role: "frontend" } },
      headers: auth_headers, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "web-01-renamed", json["host"]["name"]
  end

  # ---------------------------------------------------------------------------
  # DELETE /api/v1/hosts/:id
  # ---------------------------------------------------------------------------
  test "DELETE destroy removes the host" do
    assert_difference "Host.count", -1 do
      delete "/api/v1/hosts/#{@host.id}", headers: auth_headers, as: :json
    end
    assert_response :no_content
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
