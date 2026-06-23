class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :seat, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: 'confirmed'

      t.timestamps
    end

    add_index :reservations, [:seat_id, :start_time, :end_time]
    add_index :reservations, [:user_id, :created_at]
  end
end
