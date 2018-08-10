class AddProviderPermissionsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :provider_permissions, :string
  end
end
