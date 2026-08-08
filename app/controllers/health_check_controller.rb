# frozen_string_literal: true

class HealthCheckController < ApplicationController
  def index
    render_result(success: true, data: { status: "ok" })
  end
end
