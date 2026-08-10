# frozen_string_literal: true

module V1
  module Clients
    module PasswordResets
      class CreateService < ApplicationService
        def initialize(
          params: {},
          user_model: User
        )
          super(params:)
          @user_model = user_model
        end

        def call
          return invalid_token_error if user.nil?
          return expired_token_error if token_expired?

          if user.update(password_reset_params)
            user.client.update(
              status: :active
            )
            success(data: { message: "Password set successfully" })
          else
            error(code: "password_not_reset", message: "Failed to reset password", details: user.errors)
          end
        end

        private

        def user
          @user ||= @user_model.find_by(invite_token: @params[:invite_token])
        end

        def token_expired?
          user.invite_token_expires_at.blank? || user.invite_token_expires_at.past?
        end

        def password_reset_params
          {
            password: @params[:password],
            password_confirmation: @params[:password_confirmation],
            invite_accepted_at: Time.current,
            invite_token: nil,
            invite_token_expires_at: nil
          }
        end

        def invalid_token_error
          error(code: "invalid_invite_token", message: "Invalid invite token", details: [ "invite token not found" ])
        end

        def expired_token_error
          error(code: "invite_token_expired", message: "Invite token has expired", details: [ "invite token expired" ])
        end
      end
    end
  end
end
