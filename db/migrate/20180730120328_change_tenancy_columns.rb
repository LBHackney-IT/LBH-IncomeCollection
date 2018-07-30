class ChangeTenancyColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :tenancies, :address_1, :string
    remove_column :tenancies, :post_code, :string
    remove_column :tenancies, :current_balance, :string
    remove_column :tenancies, :primary_contact_first_name, :string
    remove_column :tenancies, :primary_contact_last_name, :string
    remove_column :tenancies, :primary_contact_title, :string

    add_column :tenancies, :primary_contact_name, :string
    add_column :tenancies, :primary_contact_short_address, :string
    add_column :tenancies, :primary_contact_postcode, :string
    add_column :tenancies, :current_balance, :string
    add_column :tenancies, :latest_action_code, :string
    add_column :tenancies, :latest_action_date, :string
    add_column :tenancies, :current_arrears_agreement_status, :string
  end
end
