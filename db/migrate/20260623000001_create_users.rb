class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.string :password_digest, null: false
      t.decimal :balance, precision: 10, scale: 2, default: 0.0
      t.string :auth_token
      t.boolean :is_admin, default: false

      t.timestamps
    end

    add_index :users, :phone, unique: true
    add_index :users, :auth_token, unique: true
  end
end
