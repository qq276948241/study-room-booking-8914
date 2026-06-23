class CreateZones < ActiveRecord::Migration[8.1]
  def change
    create_table :zones do |t|
      t.string :name, null: false
      t.string :zone_type, null: false
      t.decimal :hourly_rate, precision: 10, scale: 2, null: false
      t.text :description

      t.timestamps
    end
  end
end
