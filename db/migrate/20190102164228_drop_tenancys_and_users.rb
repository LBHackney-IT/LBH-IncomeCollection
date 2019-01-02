class DropTenancysAndUsers < ActiveRecord::Migration[5.2]
  def change
    drop_table :tenancies
    drop_table :users
  end
end
