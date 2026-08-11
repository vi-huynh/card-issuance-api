class AddIndexesForAdminReportsToCards < ActiveRecord::Migration[7.2]
  def change
    add_index :cards, :created_at
    add_index :cards, [ :client_id, :created_at ]
  end
end
