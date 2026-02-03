class CreateProcessSnapshots < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
  def change
    create_table :process_snapshots, id: false do |t|
      t.references :host, type: :uuid, null: false
      t.datetime :recorded_at, null: false

      t.integer :pid, null: false
      t.integer :ppid
      t.string :name, null: false
      t.string :command
      t.string :user
      t.string :state

      # Resources
      t.float :cpu_percent
      t.float :memory_percent
      t.bigint :memory_rss_bytes
      t.bigint :memory_vms_bytes

      # I/O
      t.bigint :io_read_bytes
      t.bigint :io_write_bytes

      # Threads/FDs
      t.integer :threads_count
      t.integer :fd_count

      # Time
      t.bigint :cpu_time_ms
      t.datetime :started_at

      t.index [ :host_id, :recorded_at ]
      t.index [ :host_id, :name, :recorded_at ]
    end

    reversible do |dir|
      dir.up do
        begin
          execute "SELECT create_hypertable('process_snapshots', 'recorded_at', if_not_exists => TRUE);"
        rescue ActiveRecord::StatementInvalid => e
          puts "TimescaleDB hypertable creation skipped: #{e.message}"
        end

        # Shorter retention for process snapshots (high cardinality)
        execute <<~SQL
          DO $$
          BEGIN
            PERFORM add_retention_policy('process_snapshots', INTERVAL '7 days', if_not_exists => TRUE);
          EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Retention policy skipped: %', SQLERRM;
          END $$;
        SQL
      end
    end
  end
end
