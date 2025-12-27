# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2023_12_24_000010) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "timescaledb"
  enable_extension "uuid-ossp"

  create_table "alert_rules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "aggregation", default: "avg"
    t.datetime "created_at", null: false
    t.jsonb "currently_firing_hosts", default: []
    t.integer "duration_seconds", default: 300
    t.boolean "enabled", default: true
    t.string "interface"
    t.datetime "last_resolved_at"
    t.datetime "last_triggered_at"
    t.string "metric", null: false
    t.string "mount_point"
    t.string "name", null: false
    t.string "operator", null: false
    t.string "platform_project_id", null: false
    t.uuid "scope_group_id"
    t.uuid "scope_host_id"
    t.jsonb "scope_tags", default: {}
    t.string "scope_type", null: false
    t.string "severity", default: "warning"
    t.uuid "signal_alert_id"
    t.float "threshold", null: false
    t.datetime "updated_at", null: false
    t.index ["platform_project_id", "enabled"], name: "index_alert_rules_on_platform_project_id_and_enabled"
    t.index ["platform_project_id"], name: "index_alert_rules_on_platform_project_id"
  end

  create_table "container_metrics", id: false, force: :cascade do |t|
    t.bigint "block_read_bytes"
    t.bigint "block_write_bytes"
    t.uuid "container_id", null: false
    t.bigint "cpu_throttled_periods"
    t.bigint "cpu_throttled_time_ns"
    t.float "cpu_usage_percent"
    t.bigint "memory_cache_bytes"
    t.bigint "memory_limit_bytes"
    t.bigint "memory_rss_bytes"
    t.float "memory_usage_percent"
    t.bigint "memory_used_bytes"
    t.bigint "network_rx_bytes"
    t.bigint "network_rx_packets"
    t.bigint "network_tx_bytes"
    t.bigint "network_tx_packets"
    t.integer "pids_current"
    t.integer "pids_limit"
    t.datetime "recorded_at", null: false
    t.index ["container_id", "recorded_at"], name: "index_container_metrics_on_container_id_and_recorded_at"
    t.index ["container_id"], name: "index_container_metrics_on_container_id"
    t.index ["recorded_at"], name: "container_metrics_recorded_at_idx", order: :desc
  end
