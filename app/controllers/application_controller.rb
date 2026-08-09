class ApplicationController < ActionController::API
  include ExceptionHandler
  include ResponseHandler

  private

  def bad_request_response(errors)
    render_result(
      success: false,
      data: { code: "bad_request", message: "Invalid request", details: errors.to_h },
      status: 400
    )
  end

  def authenticate_user!
    raise ExceptionHandler::UnauthorizedError, "Invalid token" unless (Current.user = current_user)
  end

  def authorize_admin!
    raise ExceptionHandler::ForbiddenError, "You are not authorized to perform this action" unless Current.user&.admin?
  end

  def current_user
    return @current_user if defined?(@current_user)

    token = bearer_token
    return (@current_user = nil) if token.blank?

    payload = JwtService.decode(token)
    return (@current_user = nil) if payload.blank?

    user_id = payload["user_id"] || payload[:user_id]
    return (@current_user = nil) if user_id.blank?

    @current_user = User.find_by(id: user_id)
  end

  def bearer_token
    (request.headers["Authorization"] || "").gsub("Bearer ", "")
  end
end
