module V1
  class SessionsController < ApplicationController
    before_action :authenticate_user!, only: [ :destroy ]

    def create
      validator = V1::Sessions::CreateValidator.new.call(session_params)
      if validator.failure?
        return bad_request_response(validator.errors)
      end

      result = Sessions::CreateService.new(params: validator.to_h).call
      render_result(success: result.success?, data: result.data, status: result.success? ? 200 : 401)
    end

    def destroy
      result = Sessions::DestroyService.new(current_user: Current.user).call
      render_result(success: result.success?, data: result.data, status: result.success? ? 200 : 401)
    end

    private

    def session_params
      params.permit(:email, :password).to_h
    end
  end
end
