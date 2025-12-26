class CreateHostGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :host_groups, id: :uuid do |t|
      t.string :platform_project_id, null: false

      t.string :name, null: false
      t.text :description
      t.string :color

      # Auto-assignment rules
      t.jsonb :auto_assign_rules, default: []

      t.timestamps

      t.index [:platform_project_id, :name], unique: true
      t.index :platform_project_id
    end
  end
end
