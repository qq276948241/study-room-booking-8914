class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reservation, foreign_key: true
      t.string :transaction_type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :balance_after, precision: 10, scale: 2, null: false
      t.string :description

      t.timestamps
    end

    add_index :transactions, [:user_id, :created_at]
    add_index :transactions, :transaction_type
  end
end
