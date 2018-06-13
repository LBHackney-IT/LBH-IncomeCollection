class AddPriorityBandToTenancy < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :priority_band, :string
  end
end
