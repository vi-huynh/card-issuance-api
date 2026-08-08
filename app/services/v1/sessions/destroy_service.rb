# frozen_string_literal: true

module V1
  module Sessions
    class DestroyService < ApplicationService
      def initialize(
        current_user:,
        audit_log_model: AuditLog
      )
        super(params: {})
        @current_user = current_user
        @audit_log_model = audit_log_model
      end

      def call
        @audit_log_model.create!(
          user_id: @current_user.id,
          auditable: @current_user,
          action: "log_out"
        )

        success(data: {
          message: "Successfully logged out"
        })
      end
    end
  end
end
