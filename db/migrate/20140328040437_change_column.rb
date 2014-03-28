class ChangeColumn < ActiveRecord::Migration
  def change
    change_column :citations, :authors, :text
  end
end
