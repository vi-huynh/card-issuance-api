class CreateClients < ActiveRecord::Migration[7.2]
  def change
    create_table :clients do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.decimal :payout_rate, precision: 10, scale: 2
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :clients, :status
  end
end
