# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  class UnauthorizedError < StandardError; end
  class ForbiddenError < StandardError; end

  included do
    # Order of rescue matters: More specific above more general
    # Catch-all for unhandled exceptions
    rescue_from StandardError, with: :handle_internal_server_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActionController::ParameterMissing, ActionDispatch::Http::Parameters::ParseError, with: :handle_bad_request

    # Custom-defined errors
    rescue_from ExceptionHandler::UnauthorizedError, with: :handle_unauthorized
    rescue_from ExceptionHandler::ForbiddenError, with: :handle_forbidden
  end

  private

  # --- Handlers for standard technical exceptions ---

  def handle_unauthorized(exception)
    render_result(
      success: false,
      data: {
        status: 401,
        code: "unauthorized",
        message: exception.message
      },
      status: 401
    )
  end

  def handle_forbidden(exception)
    render_result(
      success: false,
      data: {
        status: 403,
        code: "forbidden",
        message: exception.message
      },
      status: 403
    )
  end

  def handle_bad_request(exception)
    render_result(
      success: false,
      data: {
        status: 400,
        code: "bad_request",
        message: exception.message
      },
      status: 400
    )
  end

  def handle_not_found(exception)
    render_result(
      success: false,
      data: {
        status: 404,
        code: "not_found",
        message: exception.message
      },
      status: 404
    )
  end

  def handle_internal_server_error(exception)
    log_exception(exception, notify: true)
    render_result(
      success: false,
      data: {
        status: 500,
        code: "internal_server_error",
        message: "An unexpected error occurred. Please try again later."
      },
      status: 500
    )
  end

  # --- Utilities ---

  # Log exceptions for auditing/tracking/debugging
  def log_exception(exception, notify: false)
    Rails.logger.error "[#{exception.class}] #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n") if exception.backtrace

    # TODO: raise error to Application Monitoring Service (e.g., Sentry, Rollbar) if notify is true
  end
end
