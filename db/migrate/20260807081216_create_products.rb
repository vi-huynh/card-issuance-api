class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.references :brand, null: false, foreign_key: { on_delete: :restrict }
      t.string :name, null: false
      t.decimal :price, precision: 12, scale: 2, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :products, :status
  end
end
