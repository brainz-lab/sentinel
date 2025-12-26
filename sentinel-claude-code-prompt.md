# Sentinel - Host & Infrastructure Monitoring

## Overview

Sentinel monitors your servers, containers, and infrastructure. Track CPU, memory, disk, network, and processes across your entire fleet.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│                              SENTINEL                                        │
│                     "Guardian of your servers"                               │
│                                                                              │
│   ┌──────────────────────────────────────────────────────────────────────┐   │
│   │                                                                      │   │
│   │     ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │   │
│   │     │   web-prod-1    │  │   web-prod-2    │  │   web-prod-3    │   │   │
│   │     │                 │  │                 │  │                 │   │   │
│   │     │  CPU: ████░ 78% │  │  CPU: ██░░░ 42% │  │  CPU: ███░░ 61% │   │   │
│   │     │  RAM: ███░░ 65% │  │  RAM: ████░ 81% │  │  RAM: ██░░░ 45% │   │   │
│   │     │  Disk: ██░░░ 34%│  │  Disk: ██░░░ 38%│  │  Disk: █░░░░ 22%│   │   │
│   │     │                 │  │                 │  │                 │   │   │
│   │     │  ✅ Healthy     │  │  ⚠️ RAM High    │  │  ✅ Healthy     │   │   │
│   │     └─────────────────┘  └─────────────────┘  └─────────────────┘   │   │
│   │                                                                      │   │
│   │     ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │   │
│   │     │   worker-1      │  │   redis-1       │  │   postgres-1    │   │   │
│   │     │                 │  │                 │  │                 │   │   │
│   │     │  CPU: █░░░░ 15% │  │  CPU: █░░░░ 8%  │  │  CPU: ██░░░ 35% │   │   │
│   │     │  RAM: ██░░░ 40% │  │  RAM: ███░░ 55% │  │  RAM: ████░ 72% │   │   │
│   │     │  Disk: ██░░░ 40%│  │  Disk: █░░░░ 12%│  │  Disk: ███░░ 58%│   │   │
│   │     │                 │  │                 │  │                 │   │   │
│   │     │  ✅ Healthy     │  │  ✅ Healthy     │  │  ✅ Healthy     │   │   │
│   │     └─────────────────┘  └─────────────────┘  └─────────────────┘   │   │
│   │                                                                      │   │
│   └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│   │     CPU     │  │   Memory    │  │    Disk     │  │   Network   │        │
│   │   Monitor   │  │   Monitor   │  │   Monitor   │  │   Monitor   │        │
│   │             │  │             │  │             │  │             │        │
│   │ Usage, load │  │ Used, avail │  │ Space, I/O  │  │ Bandwidth   │        │
│   │ per core    │  │ swap, cache │  │ per mount   │  │ packets     │        │
│   └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                                              │
│   Features: Server metrics • Container stats • Process monitoring •         │
│             Custom metrics • Fleet overview • Alerting integration          │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **API** | Rails 8 API | Host & metrics management |
| **Agent** | Go binary | Lightweight metrics collector |
| **Database** | PostgreSQL | Host registry, configs |
| **Time-series** | TimescaleDB | Metrics storage |
| **Cache** | Redis | Real-time stats, agent heartbeats |
| **Real-time** | ActionCable | Live dashboard updates |

---

## Directory Structure

```
sentinel/
├── README.md
├── Dockerfile
├── docker-compose.yml
├── .env.example
│
├── config/
│   ├── routes.rb
│   ├── database.yml
│   └── initializers/
│       └── metrics.rb
│
├── app/
│   ├── controllers/
│   │   ├── api/v1/
│   │   │   ├── hosts_controller.rb
│   │   │   ├── metrics_controller.rb
│   │   │   ├── processes_controller.rb
│   │   │   ├── containers_controller.rb
│   │   │   ├── alerts_controller.rb
│   │   │   └── dashboards_controller.rb
│   │   └── internal/
│   │       └── agent_controller.rb
│   │
│   ├── models/
│   │   ├── host.rb
│   │   ├── host_metric.rb
│   │   ├── disk_metric.rb
│   │   ├── network_metric.rb
│   │   ├── process_snapshot.rb
│   │   ├── container.rb
│   │   ├── container_metric.rb
│   │   ├── alert_rule.rb
│   │   └── host_group.rb
│   │
│   ├── services/
│   │   ├── metric_ingester.rb
│   │   ├── host_health_checker.rb
│   │   ├── fleet_analyzer.rb
│   │   ├── anomaly_detector.rb
│   │   └── capacity_planner.rb
│   │
│   ├── jobs/
│   │   ├── check_host_health_job.rb
│   │   ├── aggregate_metrics_job.rb
│   │   ├── cleanup_old_metrics_job.rb
│   │   └── detect_anomalies_job.rb
│   │
│   └── channels/
│       ├── hosts_channel.rb
│       └── metrics_channel.rb
│
├── lib/
│   └── sentinel/
│       ├── mcp/
│       │   ├── server.rb
│       │   └── tools/
│       │       ├── list_hosts.rb
│       │       ├── host_status.rb
│       │       ├── host_metrics.rb
│       │       ├── top_processes.rb
│       │       └── fleet_overview.rb
│       └── agent/
│           └── protocol.rb
│
├── agent/                          # Go agent source
│   ├── main.go
│   ├── collector/
│   │   ├── cpu.go
│   │   ├── memory.go
│   │   ├── disk.go
│   │   ├── network.go
│   │   ├── process.go
│   │   └── container.go
│   ├── reporter/
│   │   └── http.go
│   └── config/
│       └── config.go
│
└── spec/
    ├── models/
    ├── services/
    └── requests/
```

---

## Database Schema

```ruby
# db/migrate/001_create_hosts.rb

class CreateHosts < ActiveRecord::Migration[8.0]
  def change
    create_table :hosts, id: :uuid do |t|
      t.references :platform_project, type: :uuid, null: false
      
      # Identification
      t.string :name, null: false                # web-prod-1
      t.string :hostname, null: false            # ip-10-0-1-234.ec2.internal
      t.string :agent_id, null: false            # Unique agent identifier
      
      # System info
      t.string :os                               # linux, darwin, windows
      t.string :os_version                       # Ubuntu 22.04
      t.string :kernel_version                   # 5.15.0-1019-aws
      t.string :architecture                     # x86_64, arm64
      
      # Hardware
      t.integer :cpu_cores
      t.integer :cpu_threads
      t.string :cpu_model                        # Intel Xeon E5-2686
      t.bigint :memory_total_bytes
      t.bigint :swap_total_bytes
      
      # Network
      t.string :ip_addresses, array: true, default: []
      t.string :public_ip
      t.string :private_ip
      t.string :mac_addresses, array: true, default: []
      
      # Cloud info
      t.string :cloud_provider                   # aws, gcp, digitalocean, etc.
      t.string :cloud_region                     # us-east-1
      t.string :cloud_zone                       # us-east-1a
      t.string :instance_type                    # t3.medium
      t.string :instance_id                      # i-1234567890abcdef0
      
      # Agent info
      t.string :agent_version
      t.datetime :agent_started_at
      t.datetime :last_seen_at
      t.string :status, default: 'unknown'       # online, offline, warning, critical
      
      # Organization
      t.references :host_group, type: :uuid, foreign_key: true
      t.string :environment                      # production, staging, development
      t.string :role                             # web, worker, database, cache
      t.jsonb :tags, default: {}                 # Custom tags
      
      t.timestamps
      
      t.index :platform_project_id
      t.index [:platform_project_id, :agent_id], unique: true
      t.index [:platform_project_id, :status]
      t.index [:platform_project_id, :environment]
      t.index [:platform_project_id, :role]
      t.index :last_seen_at
    end
  end
end

# db/migrate/002_create_host_groups.rb

class CreateHostGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :host_groups, id: :uuid do |t|
      t.references :platform_project, type: :uuid, null: false
      
      t.string :name, null: false                # "Web Servers", "Workers"
      t.text :description
      t.string :color                            # For UI display
      
      # Auto-assignment rules
      t.jsonb :auto_assign_rules, default: []
      # [
      #   { field: "role", operator: "eq", value: "web" },
      #   { field: "tags.team", operator: "eq", value: "platform" }
      # ]
      
      t.timestamps
      
      t.index [:platform_project_id, :name], unique: true
    end
  end
end

# db/migrate/003_create_host_metrics.rb

class CreateHostMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :host_metrics, id: false do |t|
      t.references :host, type: :uuid, null: false
      t.datetime :recorded_at, null: false
      
      # CPU
      t.float :cpu_usage_percent                 # Overall CPU usage
      t.float :cpu_user_percent                  # User space
      t.float :cpu_system_percent                # Kernel space
      t.float :cpu_iowait_percent                # Waiting for I/O
      t.float :cpu_steal_percent                 # Stolen by hypervisor
      t.float :load_1m                           # Load average 1 min
      t.float :load_5m                           # Load average 5 min
      t.float :load_15m                          # Load average 15 min
      
      # Memory
      t.bigint :memory_used_bytes
      t.bigint :memory_free_bytes
      t.bigint :memory_available_bytes
      t.bigint :memory_cached_bytes
      t.bigint :memory_buffers_bytes
      t.float :memory_usage_percent
      
      # Swap
      t.bigint :swap_used_bytes
      t.bigint :swap_free_bytes
      t.float :swap_usage_percent
      
      # Overall
      t.integer :processes_total
      t.integer :processes_running
      t.integer :processes_blocked
      t.integer :processes_zombie
      
      # Uptime
      t.bigint :uptime_seconds
      
      t.index [:host_id, :recorded_at]
    end
    
    # TimescaleDB hypertable
    execute "SELECT create_hypertable('host_metrics', 'recorded_at')"
    execute "SELECT add_compression_policy('host_metrics', INTERVAL '1 day')"
    execute "SELECT add_retention_policy('host_metrics', INTERVAL '30 days')"
    
    # Create continuous aggregates for hourly/daily rollups
    execute <<-SQL
      CREATE MATERIALIZED VIEW host_metrics_hourly
      WITH (timescaledb.continuous) AS
      SELECT
        host_id,
        time_bucket('1 hour', recorded_at) AS bucket,
        AVG(cpu_usage_percent) AS avg_cpu,
        MAX(cpu_usage_percent) AS max_cpu,
        AVG(memory_usage_percent) AS avg_memory,
        MAX(memory_usage_percent) AS max_memory,
        AVG(load_1m) AS avg_load
      FROM host_metrics
      GROUP BY host_id, bucket
    SQL
    
    execute <<-SQL
      SELECT add_continuous_aggregate_policy('host_metrics_hourly',
        start_offset => INTERVAL '3 hours',
        end_offset => INTERVAL '1 hour',
        schedule_interval => INTERVAL '1 hour'
      )
    SQL
  end
end

# db/migrate/004_create_disk_metrics.rb

class CreateDiskMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :disk_metrics, id: false do |t|
      t.references :host, type: :uuid, null: false
      t.datetime :recorded_at, null: false
      
      t.string :device, null: false              # /dev/sda1
      t.string :mount_point, null: false         # /
      t.string :filesystem                       # ext4, xfs
      
      # Space
      t.bigint :total_bytes
      t.bigint :used_bytes
      t.bigint :free_bytes
      t.float :usage_percent
      
      # Inodes
      t.bigint :inodes_total
      t.bigint :inodes_used
      t.bigint :inodes_free
      t.float :inodes_usage_percent
      
      # I/O (per interval)
      t.bigint :read_bytes
      t.bigint :write_bytes
      t.bigint :read_ops
      t.bigint :write_ops
      t.float :io_time_percent                   # % time doing I/O
      
      t.index [:host_id, :recorded_at]
      t.index [:host_id, :mount_point, :recorded_at]
    end
    
    execute "SELECT create_hypertable('disk_metrics', 'recorded_at')"
    execute "SELECT add_compression_policy('disk_metrics', INTERVAL '1 day')"
    execute "SELECT add_retention_policy('disk_metrics', INTERVAL '30 days')"
  end
end

# db/migrate/005_create_network_metrics.rb

class CreateNetworkMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :network_metrics, id: false do |t|
      t.references :host, type: :uuid, null: false
      t.datetime :recorded_at, null: false
      
      t.string :interface, null: false           # eth0, ens5
      
      # Throughput (per interval)
      t.bigint :bytes_sent
      t.bigint :bytes_received
      t.bigint :packets_sent
      t.bigint :packets_received
      
      # Errors
      t.bigint :errors_in
      t.bigint :errors_out
      t.bigint :drops_in
      t.bigint :drops_out
      
      # Connections (system-wide, only on first interface)
      t.integer :tcp_connections
      t.integer :tcp_established
      t.integer :tcp_time_wait
      t.integer :tcp_close_wait
      
      t.index [:host_id, :recorded_at]
      t.index [:host_id, :interface, :recorded_at]
    end
    
    execute "SELECT create_hypertable('network_metrics', 'recorded_at')"
    execute "SELECT add_compression_policy('network_metrics', INTERVAL '1 day')"
    execute "SELECT add_retention_policy('network_metrics', INTERVAL '30 days')"
  end
end

# db/migrate/006_create_process_snapshots.rb

class CreateProcessSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :process_snapshots, id: false do |t|
      t.references :host, type: :uuid, null: false
      t.datetime :recorded_at, null: false
      
      t.integer :pid, null: false
      t.integer :ppid                            # Parent PID
      t.string :name, null: false                # ruby, postgres, nginx
      t.string :command                          # Full command (truncated)
      t.string :user                             # Running as
      t.string :state                            # running, sleeping, zombie
      
      # Resources
      t.float :cpu_percent
      t.float :memory_percent
      t.bigint :memory_rss_bytes                 # Resident set size
      t.bigint :memory_vms_bytes                 # Virtual memory size
      
      # I/O
      t.bigint :io_read_bytes
      t.bigint :io_write_bytes
      
      # Threads/FDs
      t.integer :threads_count
      t.integer :fd_count                        # File descriptors
      
      # Time
      t.bigint :cpu_time_ms                      # Total CPU time
      t.datetime :started_at
      
      t.index [:host_id, :recorded_at]
      t.index [:host_id, :name, :recorded_at]
    end
    
    execute "SELECT create_hypertable('process_snapshots', 'recorded_at')"
    execute "SELECT add_compression_policy('process_snapshots', INTERVAL '1 day')"
    execute "SELECT add_retention_policy('process_snapshots', INTERVAL '7 days')"
  end
end

# db/migrate/007_create_containers.rb

class CreateContainers < ActiveRecord::Migration[8.0]
  def change
    create_table :containers, id: :uuid do |t|
      t.references :host, type: :uuid, null: false, foreign_key: true
      
      t.string :container_id, null: false        # Docker/container ID
      t.string :name, null: false                # Container name
      t.string :image                            # Image name:tag
      t.string :image_id
      
      t.string :runtime                          # docker, containerd, podman
      t.string :status                           # running, paused, exited
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :exit_code
      
      # Resource limits
      t.bigint :memory_limit_bytes
      t.float :cpu_limit                         # CPU cores limit
      
      # Network
      t.string :network_mode                     # bridge, host, none
      t.jsonb :port_mappings, default: []        # [{ host: 80, container: 3000 }]
      
      t.jsonb :labels, default: {}
      t.jsonb :env_vars, default: {}             # Non-sensitive only
      
      t.datetime :last_seen_at
      
      t.timestamps
      
      t.index [:host_id, :container_id], unique: true
      t.index [:host_id, :status]
    end
  end
end

# db/migrate/008_create_container_metrics.rb

class CreateContainerMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :container_metrics, id: false do |t|
      t.references :container, type: :uuid, null: false
      t.datetime :recorded_at, null: false
      
      # CPU
      t.float :cpu_usage_percent
      t.bigint :cpu_throttled_periods
      t.bigint :cpu_throttled_time_ns
      
      # Memory
      t.bigint :memory_used_bytes
      t.bigint :memory_limit_bytes
      t.float :memory_usage_percent
      t.bigint :memory_cache_bytes
      t.bigint :memory_rss_bytes
      
      # Network
      t.bigint :network_rx_bytes
      t.bigint :network_tx_bytes
      t.bigint :network_rx_packets
      t.bigint :network_tx_packets
      
      # Block I/O
      t.bigint :block_read_bytes
      t.bigint :block_write_bytes
      
      # PIDs
      t.integer :pids_current
      t.integer :pids_limit
      
      t.index [:container_id, :recorded_at]
    end
    
    execute "SELECT create_hypertable('container_metrics', 'recorded_at')"
    execute "SELECT add_compression_policy('container_metrics', INTERVAL '1 day')"
    execute "SELECT add_retention_policy('container_metrics', INTERVAL '14 days')"
  end
end

# db/migrate/009_create_alert_rules.rb

class CreateAlertRules < ActiveRecord::Migration[8.0]
  def change
    create_table :alert_rules, id: :uuid do |t|
      t.references :platform_project, type: :uuid, null: false
      
      t.string :name, null: false
      t.boolean :enabled, default: true
      
      # Scope
      t.string :scope_type, null: false          # all, group, host, tag
      t.uuid :scope_host_id                      # If specific host
      t.uuid :scope_group_id                     # If specific group
      t.jsonb :scope_tags, default: {}           # If tag-based
      
      # Condition
      t.string :metric, null: false              # cpu_usage, memory_usage, disk_usage, etc.
      t.string :operator, null: false            # gt, gte, lt, lte, eq
      t.float :threshold, null: false
      t.string :aggregation, default: 'avg'      # avg, max, min, sum
      t.integer :duration_seconds, default: 300  # Sustained for
      
      # For disk/network specific metrics
      t.string :mount_point                      # For disk metrics
      t.string :interface                        # For network metrics
      
      # Severity
      t.string :severity, default: 'warning'     # info, warning, critical
      
      # Signal integration
      t.uuid :signal_alert_id
      
      # State
      t.datetime :last_triggered_at
      t.datetime :last_resolved_at
      t.jsonb :currently_firing_hosts, default: []
      
      t.timestamps
      
      t.index [:platform_project_id, :enabled]
    end
  end
end
```

---

## Models

```ruby
# app/models/host.rb

class Host < ApplicationRecord
  belongs_to :platform_project, class_name: 'Platform::Project'
  belongs_to :host_group, optional: true
  
  has_many :host_metrics, dependent: :delete_all
  has_many :disk_metrics, dependent: :delete_all
  has_many :network_metrics, dependent: :delete_all
  has_many :process_snapshots, dependent: :delete_all
  has_many :containers, dependent: :destroy
  
  validates :name, presence: true
  validates :hostname, presence: true
  validates :agent_id, presence: true, uniqueness: { scope: :platform_project_id }
  
  enum :status, {
    unknown: 'unknown',
    online: 'online',
    offline: 'offline',
    warning: 'warning',
    critical: 'critical'
  }
  
  scope :online, -> { where(status: 'online') }
  scope :with_issues, -> { where(status: %w[warning critical]) }
  scope :by_environment, ->(env) { where(environment: env) }
  scope :by_role, ->(role) { where(role: role) }
  scope :stale, -> { where('last_seen_at < ?', 5.minutes.ago) }
  
  after_save :auto_assign_group, if: :saved_change_to_tags?
  
  def online?
    last_seen_at.present? && last_seen_at > 2.minutes.ago
  end
  
  def latest_metrics
    host_metrics.order(recorded_at: :desc).first
  end
  
  def current_cpu
    latest_metrics&.cpu_usage_percent || 0
  end
  
  def current_memory
    latest_metrics&.memory_usage_percent || 0
  end
  
  def current_load
    latest_metrics&.load_1m || 0
  end
  
  def disk_usage
    disk_metrics
      .where('recorded_at > ?', 5.minutes.ago)
      .select('DISTINCT ON (mount_point) *')
      .order(:mount_point, recorded_at: :desc)
  end
  
  def network_usage
    network_metrics
      .where('recorded_at > ?', 5.minutes.ago)
      .select('DISTINCT ON (interface) *')
      .order(:interface, recorded_at: :desc)
  end
  
  def top_processes(limit: 10)
    process_snapshots
      .where('recorded_at > ?', 2.minutes.ago)
      .order(cpu_percent: :desc)
      .limit(limit)
  end
  
  def memory_total_gb
    (memory_total_bytes.to_f / 1.gigabyte).round(1)
  end
  
  def uptime_humanized
    return 'Unknown' unless latest_metrics&.uptime_seconds
    
    ActiveSupport::Duration.build(latest_metrics.uptime_seconds).inspect
  end
  
  def update_status!
    new_status = calculate_status
    update!(status: new_status) if status != new_status
  end
  
  private
  
  def calculate_status
    return 'offline' unless online?
    
    metrics = latest_metrics
    return 'unknown' unless metrics
    
    if metrics.cpu_usage_percent > 95 || metrics.memory_usage_percent > 95
      'critical'
    elsif metrics.cpu_usage_percent > 80 || metrics.memory_usage_percent > 85
      'warning'
    else
      'online'
    end
  end
  
  def auto_assign_group
    HostGroup.where(platform_project_id: platform_project_id).find_each do |group|
      if group.matches?(self)
        update_column(:host_group_id, group.id)
        return
      end
    end
  end
end

# app/models/host_metric.rb

class HostMetric < ApplicationRecord
  belongs_to :host
  
  scope :recent, -> { where('recorded_at > ?', 1.hour.ago) }
  
  def self.cpu_series(period: 24.hours, interval: '5 minutes')
    where('recorded_at > ?', period.ago)
      .group("time_bucket('#{interval}', recorded_at)")
      .average(:cpu_usage_percent)
      .transform_values { |v| v&.round(1) }
  end
  
  def self.memory_series(period: 24.hours, interval: '5 minutes')
    where('recorded_at > ?', period.ago)
      .group("time_bucket('#{interval}', recorded_at)")
      .average(:memory_usage_percent)
      .transform_values { |v| v&.round(1) }
  end
  
  def self.load_series(period: 24.hours, interval: '5 minutes')
    where('recorded_at > ?', period.ago)
      .group("time_bucket('#{interval}', recorded_at)")
      .average(:load_1m)
      .transform_values { |v| v&.round(2) }
  end
end

# app/models/container.rb

class Container < ApplicationRecord
  belongs_to :host
  
  has_many :container_metrics, dependent: :delete_all
  
  validates :container_id, presence: true
  validates :name, presence: true
  
  scope :running, -> { where(status: 'running') }
  scope :stopped, -> { where(status: 'exited') }
  
  def latest_metrics
    container_metrics.order(recorded_at: :desc).first
  end
  
  def current_cpu
    latest_metrics&.cpu_usage_percent || 0
  end
  
  def current_memory
    latest_metrics&.memory_usage_percent || 0
  end
  
  def running?
    status == 'running'
  end
  
  def uptime
    return nil unless started_at && running?
    Time.current - started_at
  end
end

# app/models/host_group.rb

class HostGroup < ApplicationRecord
  belongs_to :platform_project, class_name: 'Platform::Project'
  
  has_many :hosts, dependent: :nullify
  
  validates :name, presence: true, uniqueness: { scope: :platform_project_id }
  
  def matches?(host)
    auto_assign_rules.all? do |rule|
      value = extract_value(host, rule['field'])
      compare(value, rule['operator'], rule['value'])
    end
  end
  
  def host_count
    hosts.count
  end
  
  def average_cpu
    hosts.joins(:host_metrics)
         .where('host_metrics.recorded_at > ?', 5.minutes.ago)
         .average('host_metrics.cpu_usage_percent')
         &.round(1) || 0
  end
  
  def average_memory
    hosts.joins(:host_metrics)
         .where('host_metrics.recorded_at > ?', 5.minutes.ago)
         .average('host_metrics.memory_usage_percent')
         &.round(1) || 0
  end
  
  private
  
  def extract_value(host, field)
    if field.start_with?('tags.')
      tag_key = field.sub('tags.', '')
      host.tags[tag_key]
    else
      host.send(field)
    end
  rescue
    nil
  end
  
  def compare(value, operator, expected)
    case operator
    when 'eq' then value == expected
    when 'neq' then value != expected
    when 'contains' then value.to_s.include?(expected.to_s)
    when 'starts_with' then value.to_s.start_with?(expected.to_s)
    when 'regex' then value.to_s.match?(Regexp.new(expected))
    else false
    end
  end
end

# app/models/alert_rule.rb

class AlertRule < ApplicationRecord
  belongs_to :platform_project, class_name: 'Platform::Project'
  
  validates :name, presence: true
  validates :metric, presence: true
  validates :operator, presence: true
  validates :threshold, presence: true, numericality: true
  
  METRICS = %w[
    cpu_usage memory_usage swap_usage load_1m load_5m load_15m
    disk_usage disk_inode_usage
    network_rx_bytes network_tx_bytes network_errors
    process_count
  ].freeze
  
  scope :enabled, -> { where(enabled: true) }
  
  def evaluate_all
    hosts_in_scope.each do |host|
      evaluate_for_host(host)
    end
  end
  
  def hosts_in_scope
    case scope_type
    when 'all'
      Host.where(platform_project_id: platform_project_id)
    when 'group'
      Host.where(host_group_id: scope_group_id)
    when 'host'
      Host.where(id: scope_host_id)
    when 'tag'
      Host.where(platform_project_id: platform_project_id)
          .where('tags @> ?', scope_tags.to_json)
    else
      Host.none
    end
  end
  
  def evaluate_for_host(host)
    value = fetch_metric_value(host)
    breached = check_threshold(value)
    
    if breached
      add_firing_host(host) unless firing_for_host?(host)
      maybe_trigger_alert(host, value)
    else
      remove_firing_host(host) if firing_for_host?(host)
      maybe_resolve_alert(host)
    end
  end
  
  private
  
  def fetch_metric_value(host)
    case metric
    when 'cpu_usage'
      host.host_metrics
          .where('recorded_at > ?', duration_seconds.seconds.ago)
          .send(aggregation, :cpu_usage_percent) || 0
    when 'memory_usage'
      host.host_metrics
          .where('recorded_at > ?', duration_seconds.seconds.ago)
          .send(aggregation, :memory_usage_percent) || 0
    when 'disk_usage'
      scope = host.disk_metrics.where('recorded_at > ?', duration_seconds.seconds.ago)
      scope = scope.where(mount_point: mount_point) if mount_point.present?
      scope.send(aggregation, :usage_percent) || 0
    when 'load_1m'
      host.host_metrics
          .where('recorded_at > ?', duration_seconds.seconds.ago)
          .send(aggregation, :load_1m) || 0
    else
      0
    end
  end
  
  def check_threshold(value)
    case operator
    when 'gt' then value > threshold
    when 'gte' then value >= threshold
    when 'lt' then value < threshold
    when 'lte' then value <= threshold
    when 'eq' then value == threshold
    else false
    end
  end
  
  def firing_for_host?(host)
    currently_firing_hosts.include?(host.id)
  end
  
  def add_firing_host(host)
    self.currently_firing_hosts = (currently_firing_hosts + [host.id]).uniq
    save!
  end
  
  def remove_firing_host(host)
    self.currently_firing_hosts = currently_firing_hosts - [host.id]
    save!
  end
  
  def maybe_trigger_alert(host, value)
    return if last_triggered_at && last_triggered_at > 5.minutes.ago
    
    Signal::Client.trigger_alert(
      source: 'sentinel',
      title: "#{name}: #{metric} threshold exceeded on #{host.name}",
      message: "Current: #{value.round(1)}, Threshold: #{operator} #{threshold}",
      severity: severity,
      data: {
        host_id: host.id,
        host_name: host.name,
        metric: metric,
        value: value,
        threshold: threshold
      }
    )
    
    update!(last_triggered_at: Time.current)
  end
  
  def maybe_resolve_alert(host)
    return unless last_triggered_at && !last_resolved_at
    return if currently_firing_hosts.any?
    
    Signal::Client.resolve_alert(
      source: 'sentinel',
      title: "#{name}: resolved"
    )
    
    update!(last_resolved_at: Time.current)
  end
end
```

---

## Services

```ruby
# app/services/metric_ingester.rb

class MetricIngester
  def initialize(host)
    @host = host
  end
  
  def ingest(payload)
    recorded_at = Time.current
    
    ActiveRecord::Base.transaction do
      ingest_host_metrics(payload[:system], recorded_at)
      ingest_disk_metrics(payload[:disks], recorded_at)
      ingest_network_metrics(payload[:network], recorded_at)
      ingest_processes(payload[:processes], recorded_at)
      ingest_containers(payload[:containers], recorded_at)
      
      @host.update!(last_seen_at: recorded_at)
    end
    
    # Check health and broadcast
    @host.update_status!
    broadcast_update
  end
  
  private
  
  def ingest_host_metrics(data, recorded_at)
    return unless data
    
    @host.host_metrics.create!(
      recorded_at: recorded_at,
      cpu_usage_percent: data[:cpu_usage],
      cpu_user_percent: data[:cpu_user],
      cpu_system_percent: data[:cpu_system],
      cpu_iowait_percent: data[:cpu_iowait],
      cpu_steal_percent: data[:cpu_steal],
      load_1m: data[:load_1m],
      load_5m: data[:load_5m],
      load_15m: data[:load_15m],
      memory_used_bytes: data[:memory_used],
      memory_free_bytes: data[:memory_free],
      memory_available_bytes: data[:memory_available],
      memory_cached_bytes: data[:memory_cached],
      memory_buffers_bytes: data[:memory_buffers],
      memory_usage_percent: data[:memory_usage],
      swap_used_bytes: data[:swap_used],
      swap_free_bytes: data[:swap_free],
      swap_usage_percent: data[:swap_usage],
      processes_total: data[:processes_total],
      processes_running: data[:processes_running],
      processes_blocked: data[:processes_blocked],
      processes_zombie: data[:processes_zombie],
      uptime_seconds: data[:uptime]
    )
  end
  
  def ingest_disk_metrics(disks, recorded_at)
    return unless disks
    
    disks.each do |disk|
      @host.disk_metrics.create!(
        recorded_at: recorded_at,
        device: disk[:device],
        mount_point: disk[:mount_point],
        filesystem: disk[:filesystem],
        total_bytes: disk[:total],
        used_bytes: disk[:used],
        free_bytes: disk[:free],
        usage_percent: disk[:usage_percent],
        inodes_total: disk[:inodes_total],
        inodes_used: disk[:inodes_used],
        inodes_free: disk[:inodes_free],
        inodes_usage_percent: disk[:inodes_usage_percent],
        read_bytes: disk[:read_bytes],
        write_bytes: disk[:write_bytes],
        read_ops: disk[:read_ops],
        write_ops: disk[:write_ops],
        io_time_percent: disk[:io_time_percent]
      )
    end
  end
  
  def ingest_network_metrics(interfaces, recorded_at)
    return unless interfaces
    
    interfaces.each do |iface|
      @host.network_metrics.create!(
        recorded_at: recorded_at,
        interface: iface[:name],
        bytes_sent: iface[:bytes_sent],
        bytes_received: iface[:bytes_received],
        packets_sent: iface[:packets_sent],
        packets_received: iface[:packets_received],
        errors_in: iface[:errors_in],
        errors_out: iface[:errors_out],
        drops_in: iface[:drops_in],
        drops_out: iface[:drops_out],
        tcp_connections: iface[:tcp_connections],
        tcp_established: iface[:tcp_established],
        tcp_time_wait: iface[:tcp_time_wait],
        tcp_close_wait: iface[:tcp_close_wait]
      )
    end
  end
  
  def ingest_processes(processes, recorded_at)
    return unless processes
    
    processes.each do |proc|
      @host.process_snapshots.create!(
        recorded_at: recorded_at,
        pid: proc[:pid],
        ppid: proc[:ppid],
        name: proc[:name],
        command: proc[:command]&.truncate(500),
        user: proc[:user],
        state: proc[:state],
        cpu_percent: proc[:cpu_percent],
        memory_percent: proc[:memory_percent],
        memory_rss_bytes: proc[:memory_rss],
        memory_vms_bytes: proc[:memory_vms],
        io_read_bytes: proc[:io_read],
        io_write_bytes: proc[:io_write],
        threads_count: proc[:threads],
        fd_count: proc[:fds],
        cpu_time_ms: proc[:cpu_time],
        started_at: proc[:started_at] ? Time.at(proc[:started_at]) : nil
      )
    end
  end
  
  def ingest_containers(containers, recorded_at)
    return unless containers
    
    containers.each do |cont|
      container = @host.containers.find_or_initialize_by(container_id: cont[:id])
      
      container.assign_attributes(
        name: cont[:name],
        image: cont[:image],
        status: cont[:status],
        started_at: cont[:started_at] ? Time.at(cont[:started_at]) : nil,
        labels: cont[:labels] || {},
        last_seen_at: recorded_at
      )
      container.save!
      
      if cont[:stats]
        container.container_metrics.create!(
          recorded_at: recorded_at,
          cpu_usage_percent: cont[:stats][:cpu_percent],
          memory_used_bytes: cont[:stats][:memory_used],
          memory_limit_bytes: cont[:stats][:memory_limit],
          memory_usage_percent: cont[:stats][:memory_percent],
          network_rx_bytes: cont[:stats][:network_rx],
          network_tx_bytes: cont[:stats][:network_tx],
          block_read_bytes: cont[:stats][:block_read],
          block_write_bytes: cont[:stats][:block_write],
          pids_current: cont[:stats][:pids]
        )
      end
    end
  end
  
  def broadcast_update
    ActionCable.server.broadcast(
      "host_#{@host.id}",
      {
        status: @host.status,
        cpu: @host.current_cpu,
        memory: @host.current_memory,
        load: @host.current_load,
        updated_at: Time.current
      }
    )
  end
end

# app/services/host_health_checker.rb

class HostHealthChecker
  THRESHOLDS = {
    cpu_warning: 80,
    cpu_critical: 95,
    memory_warning: 85,
    memory_critical: 95,
    disk_warning: 80,
    disk_critical: 90,
    load_warning_multiplier: 1.5,  # Load > cores * 1.5
    load_critical_multiplier: 2.0
  }.freeze
  
  def initialize(host)
    @host = host
  end
  
  def check
    issues = []
    
    return { status: 'offline', issues: [{ type: 'offline', message: 'Host is offline' }] } unless @host.online?
    
    metrics = @host.latest_metrics
    return { status: 'unknown', issues: [] } unless metrics
    
    # CPU check
    if metrics.cpu_usage_percent >= THRESHOLDS[:cpu_critical]
      issues << { type: 'cpu', severity: 'critical', value: metrics.cpu_usage_percent }
    elsif metrics.cpu_usage_percent >= THRESHOLDS[:cpu_warning]
      issues << { type: 'cpu', severity: 'warning', value: metrics.cpu_usage_percent }
    end
    
    # Memory check
    if metrics.memory_usage_percent >= THRESHOLDS[:memory_critical]
      issues << { type: 'memory', severity: 'critical', value: metrics.memory_usage_percent }
    elsif metrics.memory_usage_percent >= THRESHOLDS[:memory_warning]
      issues << { type: 'memory', severity: 'warning', value: metrics.memory_usage_percent }
    end
    
    # Load check
    load_warning = @host.cpu_cores * THRESHOLDS[:load_warning_multiplier]
    load_critical = @host.cpu_cores * THRESHOLDS[:load_critical_multiplier]
    
    if metrics.load_1m >= load_critical
      issues << { type: 'load', severity: 'critical', value: metrics.load_1m }
    elsif metrics.load_1m >= load_warning
      issues << { type: 'load', severity: 'warning', value: metrics.load_1m }
    end
    
    # Disk check
    @host.disk_usage.each do |disk|
      if disk.usage_percent >= THRESHOLDS[:disk_critical]
        issues << { type: 'disk', severity: 'critical', mount: disk.mount_point, value: disk.usage_percent }
      elsif disk.usage_percent >= THRESHOLDS[:disk_warning]
        issues << { type: 'disk', severity: 'warning', mount: disk.mount_point, value: disk.usage_percent }
      end
    end
    
    # Determine overall status
    status = if issues.any? { |i| i[:severity] == 'critical' }
               'critical'
             elsif issues.any? { |i| i[:severity] == 'warning' }
               'warning'
             else
               'online'
             end
    
    { status: status, issues: issues }
  end
end

# app/services/fleet_analyzer.rb

class FleetAnalyzer
  def initialize(project)
    @project = project
  end
  
  def overview
    hosts = @project.hosts
    
    {
      total_hosts: hosts.count,
      online: hosts.online.count,
      offline: hosts.where(status: 'offline').count,
      warning: hosts.where(status: 'warning').count,
      critical: hosts.where(status: 'critical').count,
      
      by_environment: hosts.group(:environment).count,
      by_role: hosts.group(:role).count,
      by_cloud: hosts.group(:cloud_provider).count,
      
      resources: aggregate_resources(hosts),
      top_cpu: top_by_metric(hosts, :cpu_usage_percent),
      top_memory: top_by_metric(hosts, :memory_usage_percent)
    }
  end
  
  def capacity_summary
    hosts = @project.hosts.online
    
    {
      total_cpu_cores: hosts.sum(:cpu_cores),
      total_memory_gb: (hosts.sum(:memory_total_bytes).to_f / 1.gigabyte).round(1),
      
      avg_cpu_usage: average_metric(hosts, :cpu_usage_percent),
      avg_memory_usage: average_metric(hosts, :memory_usage_percent),
      
      headroom: calculate_headroom(hosts)
    }
  end
  
  private
  
  def aggregate_resources(hosts)
    recent_metrics = HostMetric.joins(:host)
                               .where(hosts: { platform_project_id: @project.id })
                               .where('host_metrics.recorded_at > ?', 5.minutes.ago)
    
    {
      avg_cpu: recent_metrics.average(:cpu_usage_percent)&.round(1) || 0,
      avg_memory: recent_metrics.average(:memory_usage_percent)&.round(1) || 0,
      avg_load: recent_metrics.average(:load_1m)&.round(2) || 0
    }
  end
  
  def top_by_metric(hosts, metric, limit: 5)
    hosts.joins(:host_metrics)
         .where('host_metrics.recorded_at > ?', 5.minutes.ago)
         .select("hosts.*, host_metrics.#{metric} as current_value")
         .order("host_metrics.#{metric} DESC")
         .limit(limit)
         .map { |h| { name: h.name, value: h.current_value.round(1) } }
  end
  
  def average_metric(hosts, metric)
    HostMetric.joins(:host)
              .where(hosts: { id: hosts.pluck(:id) })
              .where('host_metrics.recorded_at > ?', 5.minutes.ago)
              .average(metric)
              &.round(1) || 0
  end
  
  def calculate_headroom(hosts)
    avg_cpu = average_metric(hosts, :cpu_usage_percent)
    avg_memory = average_metric(hosts, :memory_usage_percent)
    
    {
      cpu_headroom: (100 - avg_cpu).round(1),
      memory_headroom: (100 - avg_memory).round(1),
      can_add_load: avg_cpu < 70 && avg_memory < 70
    }
  end
end
```

---

## Go Agent

```go
// agent/main.go

package main

import (
    "flag"
    "log"
    "os"
    "os/signal"
    "syscall"
    "time"

    "sentinel-agent/collector"
    "sentinel-agent/config"
    "sentinel-agent/reporter"
)

func main() {
    configPath := flag.String("config", "/etc/sentinel/agent.yml", "Config file path")
    flag.Parse()

    cfg, err := config.Load(*configPath)
    if err != nil {
        log.Fatalf("Failed to load config: %v", err)
    }

    agent := NewAgent(cfg)
    
    // Handle graceful shutdown
    sigChan := make(chan os.Signal, 1)
    signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

    go agent.Run()

    <-sigChan
    log.Println("Shutting down agent...")
    agent.Stop()
}

type Agent struct {
    config   *config.Config
    reporter *reporter.HTTPReporter
    ticker   *time.Ticker
    done     chan bool
}

func NewAgent(cfg *config.Config) *Agent {
    return &Agent{
        config:   cfg,
        reporter: reporter.NewHTTPReporter(cfg.Endpoint, cfg.APIKey),
        done:     make(chan bool),
    }
}

func (a *Agent) Run() {
    a.ticker = time.NewTicker(time.Duration(a.config.Interval) * time.Second)
    
    // Collect and send immediately
    a.collectAndSend()

    for {
        select {
        case <-a.ticker.C:
            a.collectAndSend()
        case <-a.done:
            return
        }
    }
}

func (a *Agent) Stop() {
    a.ticker.Stop()
    a.done <- true
}

func (a *Agent) collectAndSend() {
    payload := collector.Payload{
        AgentID:   a.config.AgentID,
        Hostname:  a.config.Hostname,
        Timestamp: time.Now().UTC(),
    }

    // Collect system metrics
    payload.System = collector.CollectSystem()
    
    // Collect disk metrics
    payload.Disks = collector.CollectDisks()
    
    // Collect network metrics
    payload.Network = collector.CollectNetwork()
    
    // Collect top processes
    payload.Processes = collector.CollectProcesses(a.config.TopProcesses)
    
    // Collect container metrics if Docker available
    if a.config.CollectContainers {
        payload.Containers = collector.CollectContainers()
    }

    // Send to Sentinel API
    if err := a.reporter.Send(payload); err != nil {
        log.Printf("Failed to send metrics: %v", err)
    }
}

// agent/collector/cpu.go

package collector

import (
    "github.com/shirou/gopsutil/v3/cpu"
    "github.com/shirou/gopsutil/v3/load"
)

type SystemMetrics struct {
    CPUUsage     float64 `json:"cpu_usage"`
    CPUUser      float64 `json:"cpu_user"`
    CPUSystem    float64 `json:"cpu_system"`
    CPUIowait    float64 `json:"cpu_iowait"`
    CPUSteal     float64 `json:"cpu_steal"`
    Load1m       float64 `json:"load_1m"`
    Load5m       float64 `json:"load_5m"`
    Load15m      float64 `json:"load_15m"`
    MemoryUsed   uint64  `json:"memory_used"`
    MemoryFree   uint64  `json:"memory_free"`
    MemoryAvail  uint64  `json:"memory_available"`
    MemoryCached uint64  `json:"memory_cached"`
    MemoryUsage  float64 `json:"memory_usage"`
    SwapUsed     uint64  `json:"swap_used"`
    SwapFree     uint64  `json:"swap_free"`
    SwapUsage    float64 `json:"swap_usage"`
    ProcsTotal   int     `json:"processes_total"`
    ProcsRunning int     `json:"processes_running"`
    Uptime       uint64  `json:"uptime"`
}

func CollectSystem() *SystemMetrics {
    metrics := &SystemMetrics{}

    // CPU times
    times, _ := cpu.Times(false)
    if len(times) > 0 {
        total := times[0].User + times[0].System + times[0].Idle + times[0].Iowait + times[0].Steal
        metrics.CPUUser = times[0].User / total * 100
        metrics.CPUSystem = times[0].System / total * 100
        metrics.CPUIowait = times[0].Iowait / total * 100
        metrics.CPUSteal = times[0].Steal / total * 100
    }

    // CPU percent
    percent, _ := cpu.Percent(0, false)
    if len(percent) > 0 {
        metrics.CPUUsage = percent[0]
    }

    // Load averages
    loadAvg, _ := load.Avg()
    if loadAvg != nil {
        metrics.Load1m = loadAvg.Load1
        metrics.Load5m = loadAvg.Load5
        metrics.Load15m = loadAvg.Load15
    }

    // Memory
    collectMemory(metrics)

    // Process counts
    collectProcessCounts(metrics)

    // Uptime
    collectUptime(metrics)

    return metrics
}

// agent/collector/disk.go

package collector

import (
    "github.com/shirou/gopsutil/v3/disk"
)

type DiskMetrics struct {
    Device       string  `json:"device"`
    MountPoint   string  `json:"mount_point"`
    Filesystem   string  `json:"filesystem"`
    Total        uint64  `json:"total"`
    Used         uint64  `json:"used"`
    Free         uint64  `json:"free"`
    UsagePercent float64 `json:"usage_percent"`
    InodesTotal  uint64  `json:"inodes_total"`
    InodesUsed   uint64  `json:"inodes_used"`
    InodesFree   uint64  `json:"inodes_free"`
    ReadBytes    uint64  `json:"read_bytes"`
    WriteBytes   uint64  `json:"write_bytes"`
}

func CollectDisks() []DiskMetrics {
    var metrics []DiskMetrics

    partitions, _ := disk.Partitions(false)
    for _, p := range partitions {
        usage, err := disk.Usage(p.Mountpoint)
        if err != nil {
            continue
        }

        dm := DiskMetrics{
            Device:       p.Device,
            MountPoint:   p.Mountpoint,
            Filesystem:   p.Fstype,
            Total:        usage.Total,
            Used:         usage.Used,
            Free:         usage.Free,
            UsagePercent: usage.UsedPercent,
            InodesTotal:  usage.InodesTotal,
            InodesUsed:   usage.InodesUsed,
            InodesFree:   usage.InodesFree,
        }

        // I/O stats
        ioCounters, _ := disk.IOCounters(p.Device)
        if counter, ok := ioCounters[p.Device]; ok {
            dm.ReadBytes = counter.ReadBytes
            dm.WriteBytes = counter.WriteBytes
        }

        metrics = append(metrics, dm)
    }

    return metrics
}

// agent/collector/network.go

package collector

import (
    "github.com/shirou/gopsutil/v3/net"
)

type NetworkMetrics struct {
    Interface     string `json:"name"`
    BytesSent     uint64 `json:"bytes_sent"`
    BytesRecv     uint64 `json:"bytes_received"`
    PacketsSent   uint64 `json:"packets_sent"`
    PacketsRecv   uint64 `json:"packets_received"`
    ErrorsIn      uint64 `json:"errors_in"`
    ErrorsOut     uint64 `json:"errors_out"`
    DropsIn       uint64 `json:"drops_in"`
    DropsOut      uint64 `json:"drops_out"`
    TCPConns      int    `json:"tcp_connections"`
    TCPEstablished int   `json:"tcp_established"`
}

func CollectNetwork() []NetworkMetrics {
    var metrics []NetworkMetrics

    counters, _ := net.IOCounters(true)
    for _, c := range counters {
        if c.Name == "lo" {
            continue // Skip loopback
        }

        nm := NetworkMetrics{
            Interface:   c.Name,
            BytesSent:   c.BytesSent,
            BytesRecv:   c.BytesRecv,
            PacketsSent: c.PacketsSent,
            PacketsRecv: c.PacketsRecv,
            ErrorsIn:    c.Errin,
            ErrorsOut:   c.Errout,
            DropsIn:     c.Dropin,
            DropsOut:    c.Dropout,
        }

        metrics = append(metrics, nm)
    }

    // TCP connection stats (add to first interface)
    if len(metrics) > 0 {
        conns, _ := net.Connections("tcp")
        metrics[0].TCPConns = len(conns)
        
        established := 0
        for _, c := range conns {
            if c.Status == "ESTABLISHED" {
                established++
            }
        }
        metrics[0].TCPEstablished = established
    }

    return metrics
}

// agent/collector/process.go

package collector

import (
    "sort"

    "github.com/shirou/gopsutil/v3/process"
)

type ProcessMetrics struct {
    PID           int32   `json:"pid"`
    PPID          int32   `json:"ppid"`
    Name          string  `json:"name"`
    Command       string  `json:"command"`
    User          string  `json:"user"`
    State         string  `json:"state"`
    CPUPercent    float64 `json:"cpu_percent"`
    MemoryPercent float32 `json:"memory_percent"`
    MemoryRSS     uint64  `json:"memory_rss"`
    MemoryVMS     uint64  `json:"memory_vms"`
    Threads       int32   `json:"threads"`
    FDs           int32   `json:"fds"`
}

func CollectProcesses(limit int) []ProcessMetrics {
    procs, _ := process.Processes()
    
    var metrics []ProcessMetrics
    for _, p := range procs {
        cpu, _ := p.CPUPercent()
        mem, _ := p.MemoryPercent()
        
        pm := ProcessMetrics{
            PID:           p.Pid,
            CPUPercent:    cpu,
            MemoryPercent: mem,
        }
        
        if name, err := p.Name(); err == nil {
            pm.Name = name
        }
        if ppid, err := p.Ppid(); err == nil {
            pm.PPID = ppid
        }
        if cmdline, err := p.Cmdline(); err == nil {
            pm.Command = cmdline
        }
        if user, err := p.Username(); err == nil {
            pm.User = user
        }
        if memInfo, err := p.MemoryInfo(); err == nil {
            pm.MemoryRSS = memInfo.RSS
            pm.MemoryVMS = memInfo.VMS
        }
        if threads, err := p.NumThreads(); err == nil {
            pm.Threads = threads
        }
        if fds, err := p.NumFDs(); err == nil {
            pm.FDs = fds
        }
        
        metrics = append(metrics, pm)
    }

    // Sort by CPU and return top N
    sort.Slice(metrics, func(i, j int) bool {
        return metrics[i].CPUPercent > metrics[j].CPUPercent
    })

    if len(metrics) > limit {
        metrics = metrics[:limit]
    }

    return metrics
}

// agent/collector/container.go

package collector

import (
    "context"

    "github.com/docker/docker/api/types"
    "github.com/docker/docker/client"
)

type ContainerMetrics struct {
    ID        string            `json:"id"`
    Name      string            `json:"name"`
    Image     string            `json:"image"`
    Status    string            `json:"status"`
    StartedAt int64             `json:"started_at"`
    Labels    map[string]string `json:"labels"`
    Stats     *ContainerStats   `json:"stats"`
}

type ContainerStats struct {
    CPUPercent    float64 `json:"cpu_percent"`
    MemoryUsed    uint64  `json:"memory_used"`
    MemoryLimit   uint64  `json:"memory_limit"`
    MemoryPercent float64 `json:"memory_percent"`
    NetworkRx     uint64  `json:"network_rx"`
    NetworkTx     uint64  `json:"network_tx"`
    BlockRead     uint64  `json:"block_read"`
    BlockWrite    uint64  `json:"block_write"`
    PIDs          uint64  `json:"pids"`
}

func CollectContainers() []ContainerMetrics {
    cli, err := client.NewClientWithOpts(client.FromEnv)
    if err != nil {
        return nil
    }
    defer cli.Close()

    containers, err := cli.ContainerList(context.Background(), types.ContainerListOptions{})
    if err != nil {
        return nil
    }

    var metrics []ContainerMetrics
    for _, c := range containers {
        cm := ContainerMetrics{
            ID:        c.ID[:12],
            Name:      c.Names[0][1:], // Remove leading /
            Image:     c.Image,
            Status:    c.State,
            StartedAt: c.Created,
            Labels:    c.Labels,
        }

        // Get stats
        stats, err := cli.ContainerStats(context.Background(), c.ID, false)
        if err == nil {
            cm.Stats = parseContainerStats(stats)
            stats.Body.Close()
        }

        metrics = append(metrics, cm)
    }

    return metrics
}

// agent/reporter/http.go

package reporter

import (
    "bytes"
    "encoding/json"
    "fmt"
    "net/http"
    "time"

    "sentinel-agent/collector"
)

type HTTPReporter struct {
    endpoint string
    apiKey   string
    client   *http.Client
}

func NewHTTPReporter(endpoint, apiKey string) *HTTPReporter {
    return &HTTPReporter{
        endpoint: endpoint,
        apiKey:   apiKey,
        client: &http.Client{
            Timeout: 10 * time.Second,
        },
    }
}

func (r *HTTPReporter) Send(payload collector.Payload) error {
    data, err := json.Marshal(payload)
    if err != nil {
        return err
    }

    req, err := http.NewRequest("POST", r.endpoint+"/internal/agent", bytes.NewBuffer(data))
    if err != nil {
        return err
    }

    req.Header.Set("Content-Type", "application/json")
    req.Header.Set("Authorization", "Bearer "+r.apiKey)
    req.Header.Set("X-Agent-ID", payload.AgentID)

    resp, err := r.client.Do(req)
    if err != nil {
        return err
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        return fmt.Errorf("unexpected status: %d", resp.StatusCode)
    }

    return nil
}
```

---

## Controllers

```ruby
# app/controllers/api/v1/hosts_controller.rb

module Api
  module V1
    class HostsController < BaseController
      # GET /api/v1/hosts
      def index
        hosts = current_project.hosts
        
        # Filters
        hosts = hosts.by_environment(params[:environment]) if params[:environment]
        hosts = hosts.by_role(params[:role]) if params[:role]
        hosts = hosts.where(status: params[:status]) if params[:status]
        hosts = hosts.where(host_group_id: params[:group_id]) if params[:group_id]
        
        render json: HostSerializer.new(hosts).serializable_hash
      end
      
      # GET /api/v1/hosts/:id
      def show
        host = current_project.hosts.find(params[:id])
        
        render json: HostSerializer.new(
          host,
          include: [:latest_metrics, :disk_usage, :containers]
        ).serializable_hash
      end
      
      # GET /api/v1/hosts/:id/metrics
      def metrics
        host = current_project.hosts.find(params[:id])
        period = (params[:hours] || 24).to_i.hours
        
        render json: {
          cpu: host.host_metrics.cpu_series(period: period),
          memory: host.host_metrics.memory_series(period: period),
          load: host.host_metrics.load_series(period: period)
        }
      end
      
      # GET /api/v1/hosts/:id/processes
      def processes
        host = current_project.hosts.find(params[:id])
        
        render json: {
          processes: host.top_processes(limit: params[:limit] || 20).map do |p|
            {
              pid: p.pid,
              name: p.name,
              command: p.command,
              user: p.user,
              cpu_percent: p.cpu_percent,
              memory_percent: p.memory_percent,
              memory_rss_mb: (p.memory_rss_bytes.to_f / 1.megabyte).round(1)
            }
          end
        }
      end
      
      # GET /api/v1/hosts/:id/health
      def health
        host = current_project.hosts.find(params[:id])
        health = HostHealthChecker.new(host).check
        
        render json: health
      end
      
      # PATCH /api/v1/hosts/:id
      def update
        host = current_project.hosts.find(params[:id])
        host.update!(host_params)
        
        render json: HostSerializer.new(host).serializable_hash
      end
      
      # DELETE /api/v1/hosts/:id
      def destroy
        host = current_project.hosts.find(params[:id])
        host.destroy!
        
        head :no_content
      end
      
      private
      
      def host_params
        params.require(:host).permit(:name, :environment, :role, :host_group_id, tags: {})
      end
    end
  end
end

# app/controllers/api/v1/dashboards_controller.rb

module Api
  module V1
    class DashboardsController < BaseController
      # GET /api/v1/dashboard/fleet
      def fleet
        analyzer = FleetAnalyzer.new(current_project)
        
        render json: analyzer.overview
      end
      
      # GET /api/v1/dashboard/capacity
      def capacity
        analyzer = FleetAnalyzer.new(current_project)
        
        render json: analyzer.capacity_summary
      end
    end
  end
end

# app/controllers/internal/agent_controller.rb

module Internal
  class AgentController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_agent
    
    # POST /internal/agent
    def create
      host = find_or_create_host
      
      MetricIngester.new(host).ingest(agent_params)
      
      head :ok
    end
    
    private
    
    def authenticate_agent
      api_key = request.headers['Authorization']&.sub('Bearer ', '')
      @project = Platform::Project.find_by_api_key(api_key)
      
      head :unauthorized unless @project
    end
    
    def find_or_create_host
      agent_id = request.headers['X-Agent-ID']
      
      @project.hosts.find_or_create_by!(agent_id: agent_id) do |host|
        host.assign_attributes(
          name: agent_params[:hostname],
          hostname: agent_params[:hostname],
          os: detect_os,
          cpu_cores: agent_params.dig(:system_info, :cpu_cores),
          memory_total_bytes: agent_params.dig(:system_info, :memory_total)
        )
      end
    end
    
    def agent_params
      params.permit!.to_h.deep_symbolize_keys
    end
    
    def detect_os
      # Detect from user agent or payload
      'linux'
    end
  end
end
```

---

## MCP Tools

```ruby
# lib/sentinel/mcp/tools/list_hosts.rb

module Sentinel
  module Mcp
    module Tools
      class ListHosts < BaseTool
        TOOL_NAME = 'sentinel_list_hosts'
        DESCRIPTION = 'List all monitored hosts and their status'
        
        SCHEMA = {
          type: 'object',
          properties: {
            environment: {
              type: 'string',
              description: 'Filter by environment (production, staging, etc.)'
            },
            status: {
              type: 'string',
              enum: ['online', 'offline', 'warning', 'critical'],
              description: 'Filter by status'
            },
            role: {
              type: 'string',
              description: 'Filter by role (web, worker, database, etc.)'
            }
          }
        }.freeze
        
        def call(args)
          hosts = project.hosts
          hosts = hosts.by_environment(args[:environment]) if args[:environment]
          hosts = hosts.by_role(args[:role]) if args[:role]
          hosts = hosts.where(status: args[:status]) if args[:status]
          
          {
            hosts: hosts.map do |h|
              {
                name: h.name,
                status: h.status,
                environment: h.environment,
                role: h.role,
                cpu: h.current_cpu.round(1),
                memory: h.current_memory.round(1),
                load: h.current_load.round(2),
                uptime: h.uptime_humanized,
                last_seen: h.last_seen_at&.iso8601
              }
            end,
            summary: {
              total: hosts.count,
              online: hosts.online.count,
              issues: hosts.with_issues.count
            }
          }
        end
      end
      
      class HostStatus < BaseTool
        TOOL_NAME = 'sentinel_host_status'
        DESCRIPTION = 'Get detailed status of a specific host'
        
        SCHEMA = {
          type: 'object',
          properties: {
            host_name: {
              type: 'string',
              description: 'Host name'
            }
          },
          required: ['host_name']
        }.freeze
        
        def call(args)
          host = project.hosts.find_by!(name: args[:host_name])
          health = HostHealthChecker.new(host).check
          
          {
            name: host.name,
            status: health[:status],
            issues: health[:issues],
            
            system: {
              os: "#{host.os} #{host.os_version}",
              kernel: host.kernel_version,
              cpu_model: host.cpu_model,
              cpu_cores: host.cpu_cores,
              memory_gb: host.memory_total_gb,
              uptime: host.uptime_humanized
            },
            
            current_metrics: {
              cpu_percent: host.current_cpu.round(1),
              memory_percent: host.current_memory.round(1),
              load_1m: host.current_load.round(2)
            },
            
            disks: host.disk_usage.map do |d|
              {
                mount: d.mount_point,
                usage_percent: d.usage_percent.round(1),
                free_gb: (d.free_bytes.to_f / 1.gigabyte).round(1)
              }
            end,
            
            containers: host.containers.running.count,
            
            cloud: {
              provider: host.cloud_provider,
              region: host.cloud_region,
              instance_type: host.instance_type
            }
          }
        end
      end
      
      class HostMetrics < BaseTool
        TOOL_NAME = 'sentinel_host_metrics'
        DESCRIPTION = 'Get metrics history for a host'
        
        SCHEMA = {
          type: 'object',
          properties: {
            host_name: {
              type: 'string',
              description: 'Host name'
            },
            metric: {
              type: 'string',
              enum: ['cpu', 'memory', 'load', 'disk', 'network'],
              default: 'cpu'
            },
            period: {
              type: 'string',
              enum: ['1h', '6h', '24h', '7d'],
              default: '24h'
            }
          },
          required: ['host_name']
        }.freeze
        
        def call(args)
          host = project.hosts.find_by!(name: args[:host_name])
          period = parse_period(args[:period])
          
          case args[:metric]
          when 'cpu'
            { series: host.host_metrics.cpu_series(period: period) }
          when 'memory'
            { series: host.host_metrics.memory_series(period: period) }
          when 'load'
            { series: host.host_metrics.load_series(period: period) }
          when 'disk'
            { disks: disk_metrics(host, period) }
          when 'network'
            { interfaces: network_metrics(host, period) }
          end
        end
        
        private
        
        def parse_period(period_str)
          case period_str
          when '1h' then 1.hour
          when '6h' then 6.hours
          when '24h' then 24.hours
          when '7d' then 7.days
          else 24.hours
          end
        end
        
        def disk_metrics(host, period)
          host.disk_metrics
              .where('recorded_at > ?', period.ago)
              .group(:mount_point)
              .group("time_bucket('1 hour', recorded_at)")
              .average(:usage_percent)
        end
        
        def network_metrics(host, period)
          host.network_metrics
              .where('recorded_at > ?', period.ago)
              .group(:interface)
              .group("time_bucket('1 hour', recorded_at)")
              .sum(:bytes_received)
        end
      end
      
      class TopProcesses < BaseTool
        TOOL_NAME = 'sentinel_top_processes'
        DESCRIPTION = 'Get top processes by CPU or memory usage'
        
        SCHEMA = {
          type: 'object',
          properties: {
            host_name: {
              type: 'string',
              description: 'Host name'
            },
            sort_by: {
              type: 'string',
              enum: ['cpu', 'memory'],
              default: 'cpu'
            },
            limit: {
              type: 'integer',
              default: 10
            }
          },
          required: ['host_name']
        }.freeze
        
        def call(args)
          host = project.hosts.find_by!(name: args[:host_name])
          
          processes = host.process_snapshots
                          .where('recorded_at > ?', 2.minutes.ago)
          
          processes = case args[:sort_by]
                      when 'memory'
                        processes.order(memory_percent: :desc)
                      else
                        processes.order(cpu_percent: :desc)
                      end
          
          processes = processes.limit(args[:limit] || 10)
          
          {
            host: host.name,
            processes: processes.map do |p|
              {
                pid: p.pid,
                name: p.name,
                user: p.user,
                cpu_percent: p.cpu_percent.round(1),
                memory_percent: p.memory_percent.round(1),
                memory_mb: (p.memory_rss_bytes.to_f / 1.megabyte).round(1),
                command: p.command&.truncate(80)
              }
            end
          }
        end
      end
      
      class FleetOverview < BaseTool
        TOOL_NAME = 'sentinel_fleet_overview'
        DESCRIPTION = 'Get overview of all hosts in the fleet'
        
        SCHEMA = {
          type: 'object',
          properties: {}
        }.freeze
        
        def call(args)
          analyzer = FleetAnalyzer.new(project)
          overview = analyzer.overview
          capacity = analyzer.capacity_summary
          
          {
            hosts: {
              total: overview[:total_hosts],
              online: overview[:online],
              offline: overview[:offline],
              warning: overview[:warning],
              critical: overview[:critical]
            },
            by_environment: overview[:by_environment],
            by_role: overview[:by_role],
            resources: {
              avg_cpu: overview[:resources][:avg_cpu],
              avg_memory: overview[:resources][:avg_memory],
              avg_load: overview[:resources][:avg_load]
            },
            capacity: {
              total_cpu_cores: capacity[:total_cpu_cores],
              total_memory_gb: capacity[:total_memory_gb],
              cpu_headroom: capacity[:headroom][:cpu_headroom],
              memory_headroom: capacity[:headroom][:memory_headroom]
            },
            top_cpu: overview[:top_cpu],
            top_memory: overview[:top_memory]
          }
        end
      end
    end
  end
end
```

---

## Routes

```ruby
# config/routes.rb

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :hosts do
        member do
          get :metrics
          get :processes
          get :health
        end
        
        resources :containers, only: [:index, :show]
      end
      
      resources :host_groups
      resources :alert_rules
      
      namespace :dashboard do
        get :fleet
        get :capacity
      end
    end
  end
  
  # Agent endpoint
  namespace :internal do
    post 'agent', to: 'agent#create'
  end
  
  # Health
  get 'health', to: 'health#show'
end
```

---

## Docker Compose

```yaml
# docker-compose.yml

version: '3.8'

services:
  web:
    build: .
    ports:
      - "3010:3000"
    environment:
      - DATABASE_URL=postgres://postgres:postgres@db:5432/sentinel
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.sentinel.rule=Host(`sentinel.brainzlab.localhost`)"

  worker:
    build: .
    command: bundle exec rake solid_queue:start
    environment:
      - DATABASE_URL=postgres://postgres:postgres@db:5432/sentinel
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  db:
    image: timescale/timescaledb:latest-pg16
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=sentinel
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5440:5432"

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

---

## Agent Installation

```bash
# Install script

#!/bin/bash
# install-sentinel-agent.sh

VERSION="1.0.0"
API_KEY="${1:-$BRAINZLAB_API_KEY}"
ENDPOINT="${2:-https://sentinel.brainzlab.ai}"

if [ -z "$API_KEY" ]; then
    echo "Usage: ./install-sentinel-agent.sh <api_key> [endpoint]"
    exit 1
fi

# Detect OS and arch
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
esac

# Download agent
curl -L "https://github.com/brainzlab/sentinel-agent/releases/download/v${VERSION}/sentinel-agent-${OS}-${ARCH}" \
    -o /usr/local/bin/sentinel-agent
chmod +x /usr/local/bin/sentinel-agent

# Create config
mkdir -p /etc/sentinel
cat > /etc/sentinel/agent.yml <<EOF
agent_id: $(hostname)-$(uuidgen | cut -c1-8)
hostname: $(hostname)
endpoint: ${ENDPOINT}
api_key: ${API_KEY}
interval: 30
top_processes: 20
collect_containers: true
EOF

# Create systemd service
cat > /etc/systemd/system/sentinel-agent.service <<EOF
[Unit]
Description=Sentinel Monitoring Agent
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/sentinel-agent -config /etc/sentinel/agent.yml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Start service
systemctl daemon-reload
systemctl enable sentinel-agent
systemctl start sentinel-agent

echo "Sentinel agent installed and started!"
```

---

## Summary

### Sentinel Features

| Feature | Description |
|---------|-------------|
| **System Metrics** | CPU, memory, swap, load averages |
| **Disk Monitoring** | Space, inodes, I/O per mount |
| **Network Metrics** | Bandwidth, packets, errors, connections |
| **Process Tracking** | Top processes by CPU/memory |
| **Container Stats** | Docker/containerd metrics |
| **Fleet Overview** | Aggregate view of all hosts |
| **Host Groups** | Organize hosts with auto-assignment |
| **Alerting** | Threshold-based alerts via Signal |

### MCP Tools

| Tool | Description |
|------|-------------|
| `sentinel_list_hosts` | List all hosts with status |
| `sentinel_host_status` | Detailed host status |
| `sentinel_host_metrics` | Metrics history |
| `sentinel_top_processes` | Top processes by resource |
| `sentinel_fleet_overview` | Fleet-wide overview |

### Integration Points

| Product | Integration |
|---------|-------------|
| **Signal** | Alerts on host issues |
| **Synapse** | Deploy Agent checks server health |
| **Pulse** | Correlate app performance with host metrics |

---

*Sentinel = Guardian of your servers! 🛡️*
