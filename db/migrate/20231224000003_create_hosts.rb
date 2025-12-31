class CreateHosts < ActiveRecord::Migration[8.0]
  def change
    create_table :hosts, id: :uuid do |t|
      t.string :platform_project_id, null: false

      # Identification
      t.string :name, null: false
      t.string :hostname, null: false
      t.string :agent_id, null: false

      # System info
      t.string :os
      t.string :os_version
      t.string :kernel_version
      t.string :architecture

      # Hardware
      t.integer :cpu_cores
      t.integer :cpu_threads
      t.string :cpu_model
      t.bigint :memory_total_bytes
      t.bigint :swap_total_bytes

      # Network
      t.string :ip_addresses, array: true, default: []
      t.string :public_ip
      t.string :private_ip
      t.string :mac_addresses, array: true, default: []

      # Cloud info
      t.string :cloud_provider
      t.string :cloud_region
      t.string :cloud_zone
      t.string :instance_type
      t.string :instance_id

      # Agent info
      t.string :agent_version
      t.datetime :agent_started_at
      t.datetime :last_seen_at
      t.string :status, default: 'unknown'

      # Organization
      t.references :host_group, type: :uuid, foreign_key: true
      t.string :environment
      t.string :role
      t.jsonb :tags, default: {}

      t.timestamps

      t.index :platform_project_id
      t.index [ :platform_project_id, :agent_id ], unique: true
      t.index [ :platform_project_id, :status ]
      t.index [ :platform_project_id, :environment ]
      t.index [ :platform_project_id, :role ]
      t.index :last_seen_at
    end
  end
end
