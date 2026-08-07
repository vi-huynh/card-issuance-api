class CreateClientProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :client_products do |t|
      t.references :client, null: false, foreign_key: { on_delete: :cascade }
      t.references :product, null: false, foreign_key: { on_delete: :restrict }

      t.datetime :created_at, null: false
    end
    add_index :client_products, [ :client_id, :product_id ], unique: true
  end
end
