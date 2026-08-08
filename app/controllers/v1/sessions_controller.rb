module V1
  class SessionsController < ApplicationController
    def create
      validator = V1::Sessions::CreateValidator.new.call(session_params)
      if validator.failure?
        return bad_request_response(validator.errors)
      end

      result = Sessions::CreateService.new(params: validator.to_h).call
      render_result(success: result.success?, data: result.data, status: result.success? ? 200 : 401)
    end

    private

    def session_params
      params.permit(:email, :password).to_h
    end
  end
end
