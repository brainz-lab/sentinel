class CreateDiskMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :disk_metrics, id: false do |t|
      t.references :host, type: :uuid, null: false
      t.datetime :recorded_at, null: false

      t.string :device, null: false
      t.string :mount_point, null: false
      t.string :filesystem

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
      t.float :io_time_percent

      t.index [:host_id, :recorded_at]
      t.index [:host_id, :mount_point, :recorded_at]
    end

    reversible do |dir|
      dir.up do
        begin
          execute "SELECT create_hypertable('disk_metrics', 'recorded_at', if_not_exists => TRUE);"
        rescue ActiveRecord::StatementInvalid => e
          puts "TimescaleDB hypertable creation skipped: #{e.message}"
        end

        begin
          execute "SELECT add_retention_policy('disk_metrics', INTERVAL '30 days', if_not_exists => TRUE);"
        rescue ActiveRecord::StatementInvalid => e
          puts "TimescaleDB retention policy skipped: #{e.message}"
        end
      end
    end
  end
end
