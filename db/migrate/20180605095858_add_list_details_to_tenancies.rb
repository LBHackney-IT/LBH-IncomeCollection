class AddListDetailsToTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :address_1, :string
    add_column :tenancies, :post_code, :string
    add_column :tenancies, :current_balance, :string
    add_column :tenancies, :primary_contact_first_name, :string
    add_column :tenancies, :primary_contact_last_name, :string
    add_column :tenancies, :primary_contact_title, :string
  end
end
