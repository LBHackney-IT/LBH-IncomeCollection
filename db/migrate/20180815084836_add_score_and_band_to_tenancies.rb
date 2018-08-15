class AddScoreAndBandToTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :score, :string
    add_column :tenancies, :band, :string
  end
end
