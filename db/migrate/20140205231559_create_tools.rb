class CreateTools < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.string :url
      t.string :doi
      t.text :description
      t.hstore :metadata

      t.timestamps
    end
  end
end
