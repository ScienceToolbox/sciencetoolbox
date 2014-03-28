class AddMoreColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :oauth_token, :string
    add_column :users, :oauth_secret, :string
    add_column :users, :orcid, :string
    add_column :users, :nickname, :string
    add_column :users, :avatar, :string
  end
end
