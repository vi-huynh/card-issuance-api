module V1
  module Clients
    class ProductsController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_client!

      def index
        validator = V1::Clients::Products::IndexValidator.new.call(index_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Clients::Products::IndexService.new(client: Current.user.client, params: validator.to_h).call
        render_result(
          success: true,
          data: {
            items: ActiveModel::Serializer::CollectionSerializer.new(result.data[:items], serializer: V1::Clients::Products::ProductSerializer),
            pagination: result.data[:pagination]
          }
        )
      end

      private

      def index_params
        params.permit(:page, :per_page, :sort_by, :sort_order, :brand_name, :name, :min_price, :max_price, :status).to_h
      end
    end
  end
end
