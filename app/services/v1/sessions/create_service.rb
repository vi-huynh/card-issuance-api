# frozen_string_literal: true

module V1
  module Sessions
    class CreateService < ApplicationService
      MAX_FAILED_ATTEMPTS = 5
      def initialize(
        params: {},
        user_model: User,
        audit_log_model: AuditLog,
        jwt_service: JwtService
      )
        super(params:)
        @user_model = user_model
        @audit_log_model = audit_log_model
        @jwt_service = jwt_service
      end

      def call
        if locked_user?
          return error(
            code: "account_locked",
            message: "Account is locked due to too many failed login attempts. Please try again later.",
            details: [ "account locked" ]
          )
        end
        
        do_validation

        if @errors.any?
          @audit_log_model.create!(
            user_id: user&.id,
            auditable: user,
            action: "login_failed",
            object: { email: @params[:email], errors: @errors }
          )
          return error(
            code: "invalid_credentials",
            message: "Invalid email or password",
            details: @errors
          )
        else
          @audit_log_model.create!(
            user_id: user.id,
            auditable: user,
            action: "login_success"
          )
        end

        access_token = access_token(user)
        success(data: {
          access_token:,
          user: { id: user.id, email: user.email }
        })
      end

      private

      def locked_user?
        return false if user.blank?

        AuditLog.where(user_id: user&.id, action: "login_failed").where("created_at >= ?", 15.minutes.ago).count >= MAX_FAILED_ATTEMPTS
      end

      def user
        @user ||= @user_model.find_by(email: @params[:email])
      end

      def do_validation
        @errors = []
        @errors << "invalid credentials" if user.blank? || !user.authenticate(@params[:password])
      end

      def access_token(user)
        @jwt_service.encode({ "user_id" => user.id })
      end
    end
  end
end
