# frozen_string_literal: true

module ResponseHandler
  extend ActiveSupport::Concern

  private

  #
  # Success:
  # - { data: {...} }
  # - { data: [...], meta: {...} }
  #
  # Error:
  # - { error: { code:, message:, details: {} } }
  def render_result(success:, data:, status: 200)
    if success
      render json: { data: data }, status: status
    else
      render json: { error: data }, status: status
    end
  end
end
