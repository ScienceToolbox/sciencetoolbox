class CreateToolVersions < ActiveRecord::Migration
  def change
    create_table :tool_versions do |t|
      t.integer :tool_id
      t.string :url

      t.timestamps null: false
    end
  end
end
