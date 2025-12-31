class CreateAlertRules < ActiveRecord::Migration[8.0]
  def change
    create_table :alert_rules, id: :uuid do |t|
      t.string :platform_project_id, null: false

      t.string :name, null: false
      t.boolean :enabled, default: true

      # Scope
      t.string :scope_type, null: false
      t.uuid :scope_host_id
      t.uuid :scope_group_id
      t.jsonb :scope_tags, default: {}

      # Condition
      t.string :metric, null: false
      t.string :operator, null: false
      t.float :threshold, null: false
      t.string :aggregation, default: 'avg'
      t.integer :duration_seconds, default: 300

      # For disk/network specific metrics
      t.string :mount_point
      t.string :interface

      # Severity
      t.string :severity, default: 'warning'

      # Signal integration
      t.uuid :signal_alert_id

      # State
      t.datetime :last_triggered_at
      t.datetime :last_resolved_at
      t.jsonb :currently_firing_hosts, default: []

      t.timestamps

      t.index [ :platform_project_id, :enabled ]
      t.index :platform_project_id
    end
  end
end
