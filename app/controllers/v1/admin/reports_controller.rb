module V1
  module Admin
    class ReportsController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_admin!

      def show
        validator = V1::Admin::Reports::ShowValidator.new.call(report_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Admin::Reports::ShowService.new(params: validator.to_h).call
        render_result(success: result.success?, data: result.data)
      end

      private

      def report_params
        params.permit(:brand_id, :client_id, :date_from, :date_to).to_h
      end
    end
  end
end
