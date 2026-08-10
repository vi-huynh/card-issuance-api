class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0
      t.string :invite_token
      t.datetime :invite_token_expires_at
      t.datetime :invited_at
      t.datetime :invite_accepted_at

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :invite_token, unique: true
  end
end
