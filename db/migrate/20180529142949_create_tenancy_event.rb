class CreateTenancyEvent < ActiveRecord::Migration[5.2]
  def change
    create_table :tenancy_events do |t|
      t.string :event_type
      t.string :description
      t.boolean :automated
      t.references :tenancy, foreign_key: true
    end
  end
end
