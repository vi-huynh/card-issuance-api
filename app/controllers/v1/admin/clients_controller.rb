module V1
  module Admin
    class ClientsController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_admin!

      def index
        validator = V1::Admin::Clients::IndexValidator.new.call(index_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Admin::Clients::IndexService.new(params: validator.to_h).call
        render_result(
          success: result.success?,
          data: {
            items: ActiveModel::Serializer::CollectionSerializer.new(result.data[:items], serializer: V1::Admin::Clients::ClientSerializer),
            pagination: result.data[:pagination]
          }
        )
      end

      def create
        validator = V1::Admin::Clients::CreateValidator.new.call(client_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Admin::Clients::CreateService.new(params: validator.to_h).call

        if result.success?
          render_result(
            success: true,
            data: V1::Admin::Clients::ClientSerializer.new(result.data[:client]),
            status: 201
          )
        else
          render_result(
            success: false,
            data: result.data,
            status: 422
          )
        end
      end

      private

      def client_params
        params.permit(:email, :name, :payout_rate).to_h
      end

      def index_params
        params.permit(:page, :per_page, :sort_by, :sort_order).to_h
      end
    end
  end
end
