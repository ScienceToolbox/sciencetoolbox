class CreateToolsUsers < ActiveRecord::Migration
  def change
    create_table :tools_users do |t|
      t.integer :tool_id, :null => false
      t.integer :user_id, :null => false
    end

    # Add table index
    add_index :tools_users, [:tool_id, :user_id], :unique => true
  end
end
