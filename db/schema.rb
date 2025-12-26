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

  create_table "containers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "container_id", null: false
    t.float "cpu_limit"
    t.datetime "created_at", null: false
    t.jsonb "env_vars", default: {}
    t.integer "exit_code"
    t.datetime "finished_at"
    t.uuid "host_id", null: false
    t.string "image"
    t.string "image_id"
    t.jsonb "labels", default: {}
    t.datetime "last_seen_at"
    t.bigint "memory_limit_bytes"
    t.string "name", null: false
    t.string "network_mode"
    t.jsonb "port_mappings", default: []
    t.string "runtime"
    t.datetime "started_at"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["host_id", "container_id"], name: "index_containers_on_host_id_and_container_id", unique: true
    t.index ["host_id", "status"], name: "index_containers_on_host_id_and_status"
    t.index ["host_id"], name: "index_containers_on_host_id"
  end

  create_table "disk_metrics", id: false, force: :cascade do |t|
    t.string "device", null: false
    t.string "filesystem"
    t.bigint "free_bytes"
    t.uuid "host_id", null: false
    t.bigint "inodes_free"
    t.bigint "inodes_total"
    t.float "inodes_usage_percent"
    t.bigint "inodes_used"
    t.float "io_time_percent"
    t.string "mount_point", null: false
    t.bigint "read_bytes"
    t.bigint "read_ops"
    t.datetime "recorded_at", null: false
    t.bigint "total_bytes"
    t.float "usage_percent"
    t.bigint "used_bytes"
    t.bigint "write_bytes"
    t.bigint "write_ops"
    t.index ["host_id", "mount_point", "recorded_at"], name: "index_disk_metrics_on_host_id_and_mount_point_and_recorded_at"
    t.index ["host_id", "recorded_at"], name: "index_disk_metrics_on_host_id_and_recorded_at"
    t.index ["host_id"], name: "index_disk_metrics_on_host_id"
    t.index ["recorded_at"], name: "disk_metrics_recorded_at_idx", order: :desc
  end

  create_table "host_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "auto_assign_rules", default: []
    t.string "color"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "platform_project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["platform_project_id", "name"], name: "index_host_groups_on_platform_project_id_and_name", unique: true
    t.index ["platform_project_id"], name: "index_host_groups_on_platform_project_id"
  end

  create_table "host_metrics", id: false, force: :cascade do |t|
    t.float "cpu_iowait_percent"
    t.float "cpu_steal_percent"
    t.float "cpu_system_percent"
    t.float "cpu_usage_percent"
    t.float "cpu_user_percent"
    t.uuid "host_id", null: false
    t.float "load_15m"
    t.float "load_1m"
    t.float "load_5m"
    t.bigint "memory_available_bytes"
    t.bigint "memory_buffers_bytes"
    t.bigint "memory_cached_bytes"
    t.bigint "memory_free_bytes"
    t.float "memory_usage_percent"
    t.bigint "memory_used_bytes"
    t.integer "processes_blocked"
    t.integer "processes_running"
    t.integer "processes_total"
    t.integer "processes_zombie"
    t.datetime "recorded_at", null: false
    t.bigint "swap_free_bytes"
    t.float "swap_usage_percent"
    t.bigint "swap_used_bytes"
    t.bigint "uptime_seconds"
    t.index ["host_id", "recorded_at"], name: "index_host_metrics_on_host_id_and_recorded_at"
    t.index ["host_id"], name: "index_host_metrics_on_host_id"
    t.index ["recorded_at"], name: "host_metrics_recorded_at_idx", order: :desc
  end

  create_table "hosts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "agent_id", null: false
    t.datetime "agent_started_at"
    t.string "agent_version"
    t.string "architecture"
    t.string "cloud_provider"
    t.string "cloud_region"
    t.string "cloud_zone"
    t.integer "cpu_cores"
    t.string "cpu_model"
    t.integer "cpu_threads"
    t.datetime "created_at", null: false
    t.string "environment"
    t.uuid "host_group_id"
    t.string "hostname", null: false
    t.string "instance_id"
    t.string "instance_type"
    t.string "ip_addresses", default: [], array: true
    t.string "kernel_version"
    t.datetime "last_seen_at"
    t.string "mac_addresses", default: [], array: true
    t.bigint "memory_total_bytes"
    t.string "name", null: false
    t.string "os"
    t.string "os_version"
    t.string "platform_project_id", null: false
    t.string "private_ip"
    t.string "public_ip"
    t.string "role"
    t.string "status", default: "unknown"
    t.bigint "swap_total_bytes"
    t.jsonb "tags", default: {}
    t.datetime "updated_at", null: false
    t.index ["host_group_id"], name: "index_hosts_on_host_group_id"
    t.index ["last_seen_at"], name: "index_hosts_on_last_seen_at"
    t.index ["platform_project_id", "agent_id"], name: "index_hosts_on_platform_project_id_and_agent_id", unique: true
    t.index ["platform_project_id", "environment"], name: "index_hosts_on_platform_project_id_and_environment"
    t.index ["platform_project_id", "role"], name: "index_hosts_on_platform_project_id_and_role"
    t.index ["platform_project_id", "status"], name: "index_hosts_on_platform_project_id_and_status"
    t.index ["platform_project_id"], name: "index_hosts_on_platform_project_id"
  end

  create_table "network_metrics", id: false, force: :cascade do |t|
    t.bigint "bytes_received"
    t.bigint "bytes_sent"
    t.bigint "drops_in"
    t.bigint "drops_out"
    t.bigint "errors_in"
    t.bigint "errors_out"
    t.uuid "host_id", null: false
    t.string "interface", null: false
    t.bigint "packets_received"
    t.bigint "packets_sent"
    t.datetime "recorded_at", null: false
    t.integer "tcp_close_wait"
    t.integer "tcp_connections"
    t.integer "tcp_established"
    t.integer "tcp_time_wait"
    t.index ["host_id", "interface", "recorded_at"], name: "index_network_metrics_on_host_id_and_interface_and_recorded_at"
    t.index ["host_id", "recorded_at"], name: "index_network_metrics_on_host_id_and_recorded_at"
    t.index ["host_id"], name: "index_network_metrics_on_host_id"
    t.index ["recorded_at"], name: "network_metrics_recorded_at_idx", order: :desc
  end

  create_table "process_snapshots", id: false, force: :cascade do |t|
    t.string "command"
    t.float "cpu_percent"
    t.bigint "cpu_time_ms"
    t.integer "fd_count"
    t.uuid "host_id", null: false
    t.bigint "io_read_bytes"
    t.bigint "io_write_bytes"
    t.float "memory_percent"
    t.bigint "memory_rss_bytes"
    t.bigint "memory_vms_bytes"
    t.string "name", null: false
    t.integer "pid", null: false
    t.integer "ppid"
    t.datetime "recorded_at", null: false
    t.datetime "started_at"
    t.string "state"
    t.integer "threads_count"
    t.string "user"
    t.index ["host_id", "name", "recorded_at"], name: "index_process_snapshots_on_host_id_and_name_and_recorded_at"
    t.index ["host_id", "recorded_at"], name: "index_process_snapshots_on_host_id_and_recorded_at"
    t.index ["host_id"], name: "index_process_snapshots_on_host_id"
    t.index ["recorded_at"], name: "process_snapshots_recorded_at_idx", order: :desc
  end

  add_foreign_key "containers", "hosts"
  add_foreign_key "hosts", "host_groups"
end
