class ChangeAuditLogsNullableForAnonymousActions < ActiveRecord::Migration[7.2]
  def change
    # Failed/anonymous login attempts have no authenticated actor and no
    # specific record being audited (e.g. an unknown email address).
    change_column_null :audit_logs, :user_id, true
    change_column_null :audit_logs, :auditable_type, true
    change_column_null :audit_logs, :auditable_id, true
  end
end
