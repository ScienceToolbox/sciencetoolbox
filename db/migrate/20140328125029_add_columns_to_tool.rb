class AddColumnsToTool < ActiveRecord::Migration
  def change
    add_column :tools, :test, :boolean, default: false
    add_column :tools, :virtualization, :boolean, default: false
    add_column :tools, :license, :boolean, default: false
    add_column :tools, :readme, :boolean, default: false
    add_column :tools, :ci, :boolean, default: false
  end
end
