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
end
