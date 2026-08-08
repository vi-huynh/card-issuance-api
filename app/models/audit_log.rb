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
    delete: "delete"
  }, prefix: true
end
