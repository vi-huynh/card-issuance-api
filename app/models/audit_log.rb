# frozen_string_literal: true

class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  enum :action, {
    login_success: "login_success",
    login_failed: "login_failed",
    log_out: "log_out",
    create: "create",
    update: "update",
    destroy: "destroy"
  }, prefix: true

  class << self
    def record(auditable, action, user = nil)
      create!(
        auditable: auditable,
        action: action,
        user: user,
        object: auditable.attributes,
        object_changes: auditable.previous_changes.except(:updated_at),
        ip_address: Current.ip_address
      )
    end
  end
end
