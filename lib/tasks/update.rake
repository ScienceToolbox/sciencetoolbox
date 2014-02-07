namespace :update do
  desc "Refetch all tools from coresponding APIs"
  task all: :environment do
    Tool.find_each do |tool|
      tool.save
      puts "Tool #{tool.id} updated to: #{tool.to_yaml}"
    end
  end
end