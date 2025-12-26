class CreateContainers < ActiveRecord::Migration[8.0]
  def change
    create_table :containers, id: :uuid do |t|
      t.references :host, type: :uuid, null: false, foreign_key: true

      t.string :container_id, null: false
      t.string :name, null: false
      t.string :image
      t.string :image_id

      t.string :runtime
      t.string :status
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :exit_code

      # Resource limits
      t.bigint :memory_limit_bytes
      t.float :cpu_limit

      # Network
      t.string :network_mode
      t.jsonb :port_mappings, default: []

      t.jsonb :labels, default: {}
      t.jsonb :env_vars, default: {}

      t.datetime :last_seen_at

      t.timestamps

      t.index [:host_id, :container_id], unique: true
      t.index [:host_id, :status]
    end
  end
end
