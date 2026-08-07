class CreateBrands < ActiveRecord::Migration[7.2]
  def change
    create_table :brands do |t|
      t.string :name, null: false
      t.text :description
      t.text :logo_url
      t.string :contact_email

      t.timestamps
    end
  end
end
