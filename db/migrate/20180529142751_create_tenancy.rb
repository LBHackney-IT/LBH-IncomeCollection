class CreateTenancy < ActiveRecord::Migration[5.2]
  def change
    create_table :tenancies do |t|
      t.string :ref, index: { unique: true }
    end
  end
end
