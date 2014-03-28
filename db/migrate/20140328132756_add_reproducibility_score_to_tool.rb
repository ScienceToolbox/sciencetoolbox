class AddReproducibilityScoreToTool < ActiveRecord::Migration
  def change
    add_column :tools, :reproducibility_score, :integer, default: 0
  end
end
