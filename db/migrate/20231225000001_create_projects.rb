class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects, id: :uuid do |t|
      t.string :platform_project_id, null: false
      t.string :name, null: false
      t.string :slug
      t.string :environment, default: 'production'
      t.jsonb :settings, default: {}
      t.timestamps
    end

    add_index :projects, :platform_project_id, unique: true
    add_index :projects, :slug

    # Add project_id foreign keys to existing tables
    add_reference :hosts, :project, type: :uuid, foreign_key: true, index: true
    add_reference :host_groups, :project, type: :uuid, foreign_key: true, index: true
    add_reference :alert_rules, :project, type: :uuid, foreign_key: true, index: true
  end
end
