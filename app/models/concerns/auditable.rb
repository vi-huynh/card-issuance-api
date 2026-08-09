module Auditable
  extend ActiveSupport::Concern

  included do
    after_create  -> { AuditLog.record(self, "create", Current.user) }
    after_update  -> { AuditLog.record(self, "update", Current.user) }
    after_destroy -> { AuditLog.record(self, "destroy", Current.user) }
  end
end
