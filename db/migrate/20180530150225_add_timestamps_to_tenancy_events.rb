class AddTimestampsToTenancyEvents < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :tenancy_events, null: true
  end
end
