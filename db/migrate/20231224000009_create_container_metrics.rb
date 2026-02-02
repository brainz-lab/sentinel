class CreateContainerMetrics < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
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

      t.index [ :container_id, :recorded_at ]
    end

    reversible do |dir|
      dir.up do
        begin
          execute "SELECT create_hypertable('container_metrics', 'recorded_at', if_not_exists => TRUE);"
        rescue ActiveRecord::StatementInvalid => e
          puts "TimescaleDB hypertable creation skipped: #{e.message}"
        end

        begin
          execute "SELECT add_retention_policy('container_metrics', INTERVAL '14 days', if_not_exists => TRUE);"
        rescue ActiveRecord::StatementInvalid => e
          puts "TimescaleDB retention policy skipped: #{e.message}"
        end
      end
    end
  end
end
