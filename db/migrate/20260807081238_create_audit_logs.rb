class CreateAuditLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: false, foreign_key: { on_delete: :restrict }
      t.string :action, null: false
      t.references :auditable, polymorphic: true, null: false
      t.jsonb :object, default: {}
      t.jsonb :object_changes, default: {}
      t.inet :ip_address
      t.datetime :created_at, null: false
    end
    add_index :audit_logs, :created_at
  end
end
