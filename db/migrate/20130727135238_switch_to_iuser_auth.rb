class SwitchToIuserAuth < ActiveRecord::Migration
  def change
    remove_column :users, :github_uid
    remove_column :users, :github_nickname
    add_column :users, :ein, :string
  end
end
