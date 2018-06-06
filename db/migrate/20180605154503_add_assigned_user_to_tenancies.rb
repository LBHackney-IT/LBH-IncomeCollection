class AddAssignedUserToTenancies < ActiveRecord::Migration[5.2]
  def change
    add_reference :tenancies, :assigned_user, foreign_key: { to_table: :users }
  end
end
