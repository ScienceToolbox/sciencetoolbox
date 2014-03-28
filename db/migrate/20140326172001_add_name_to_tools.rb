class AddNameToTools < ActiveRecord::Migration
  def change
    add_column :tools, :name, :string

    Tool.find_each do |tool|
      if tool.metadata
        tool.name = tool.metadata['name']
        tool.save
      end
    end
  end
end
