class AddDescriptionToTool < ActiveRecord::Migration
  def up
    Tool.find_each do |tool|
      tool.update_attribute(:description, tool.metadata['description'])
    end
  end

  def down
    Tool.find_each do |tool|
      tool.update_attribute(:description, nil)
    end
  end
end
