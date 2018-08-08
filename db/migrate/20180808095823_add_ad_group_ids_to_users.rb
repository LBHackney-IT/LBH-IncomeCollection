class AddAdGroupIdsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :ad_groups, :string
  end
end
