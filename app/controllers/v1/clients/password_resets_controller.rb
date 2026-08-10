module V1
  module Clients
    class PasswordResetsController < ApplicationController
      def create
        validator = V1::Clients::PasswordResets::CreateValidator.new.call(password_reset_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Clients::PasswordResets::CreateService.new(params: validator.to_h).call

        if result.success?
          render_result(success: true, data: result.data)
        else
          render_result(success: false, data: result.data, status: 422)
        end
      end

      private

      def password_reset_params
        params.permit(:invite_token, :password, :password_confirmation).to_h
      end
    end
  end
end
