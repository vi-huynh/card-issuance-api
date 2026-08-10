class CreateCards < ActiveRecord::Migration[7.2]
  def change
    create_table :cards do |t|
      t.references :client, null: false, foreign_key: { on_delete: :restrict }
      t.references :product, null: false, foreign_key: { on_delete: :restrict }
      t.string :activation_number, null: false
      t.string :pin_digest
      t.integer :status, null: false, default: 0
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.decimal :current_balance, precision: 12, scale: 2, null: false
      t.string :currency, limit: 3, null: false, default: "USD"
      t.jsonb :purchase_details, default: {}

      t.timestamps
    end
    add_index :cards, :activation_number, unique: true
    add_index :cards, :status
  end
end
