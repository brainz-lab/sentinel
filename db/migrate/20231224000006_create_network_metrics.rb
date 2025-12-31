class CreateNetworkMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :network_metrics, id: false do |t|
      t.references :host, type: :uuid, null: false
      t.datetime :recorded_at, null: false

      t.string :interface, null: false

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

      t.index [ :host_id, :recorded_at ]
      t.index [ :host_id, :interface, :recorded_at ]
    end

    reversible do |dir|
      dir.up do
        begin
          execute "SELECT create_hypertable('network_metrics', 'recorded_at', if_not_exists => TRUE);"
        rescue ActiveRecord::StatementInvalid => e
          puts "TimescaleDB hypertable creation skipped: #{e.message}"
        end

        begin
          execute "SELECT add_retention_policy('network_metrics', INTERVAL '30 days', if_not_exists => TRUE);"
        rescue ActiveRecord::StatementInvalid => e
          puts "TimescaleDB retention policy skipped: #{e.message}"
        end
      end
    end
  end
end
