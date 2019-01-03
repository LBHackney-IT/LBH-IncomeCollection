class DropTenancyEventTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :tenancy_events
  end
end
