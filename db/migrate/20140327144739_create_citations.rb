class CreateCitations < ActiveRecord::Migration
  def change
    create_table :citations do |t|
      t.datetime :published_at
      t.string :title
      t.string :authors
      t.string :journal
      t.string :doi
      t.integer :tool_id
      t.hstore :metadata
      t.timestamps
    end
  end
end
