class CreateSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :seats do |t|
      t.references :zone, null: false, foreign_key: true
      t.string :seat_number, null: false
      t.boolean :has_monitor, default: false
      t.boolean :has_power_outlet, default: true
      t.text :equipment_notes
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :seats, [:zone_id, :seat_number], unique: true
  end
end
