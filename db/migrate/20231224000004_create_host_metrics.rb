class CreateHostMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :host_metrics, id: false do |t|
      t.references :host, type: :uuid, null: false
      t.datetime :recorded_at, null: false

      # CPU
      t.float :cpu_usage_percent
      t.float :cpu_user_percent
      t.float :cpu_system_percent
      t.float :cpu_iowait_percent
      t.float :cpu_steal_percent
      t.float :load_1m
      t.float :load_5m
      t.float :load_15m

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

      # Processes
      t.integer :processes_total
      t.integer :processes_running
      t.integer :processes_blocked
      t.integer :processes_zombie

      # Uptime
      t.bigint :uptime_seconds

      t.index [:host_id, :recorded_at]
    end

    # TimescaleDB hypertable - will be executed if TimescaleDB is available
    reversible do |dir|
      dir.up do
        begin
          execute "SELECT create_hypertable('host_metrics', 'recorded_at', if_not_exists => TRUE);"
        rescue ActiveRecord::StatementInvalid => e
          puts "TimescaleDB hypertable creation skipped: #{e.message}"
        end

        begin
          execute "SELECT add_retention_policy('host_metrics', INTERVAL '30 days', if_not_exists => TRUE);"
        rescue ActiveRecord::StatementInvalid => e
          puts "TimescaleDB retention policy skipped: #{e.message}"
        end
      end
    end
  end
end
