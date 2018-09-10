class RemoveUnusedTenancyColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :tenancies, :primary_contact_name, :string
    remove_column :tenancies, :primary_contact_short_address, :string
    remove_column :tenancies, :primary_contact_postcode, :string
    remove_column :tenancies, :current_balance, :string
    remove_column :tenancies, :latest_action_code, :string
    remove_column :tenancies, :latest_action_date, :string
    remove_column :tenancies, :current_arrears_agreement_status, :string
  end
end
