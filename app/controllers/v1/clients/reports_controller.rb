module V1
  module Clients
    class ReportsController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_client!

      def show
        validator = V1::Clients::Reports::ShowValidator.new.call(report_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Clients::Reports::ShowService.new(client: Current.user.client, params: validator.to_h).call
        render_result(success: result.success?, data: result.data)
      end

      private

      def report_params
        params.permit(:date_from, :date_to).to_h
      end
    end
  end
end
