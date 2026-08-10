module V1
  module Clients
    class CardsController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_client!

      def create
        validator = V1::Clients::Cards::CreateValidator.new.call(card_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        product = Product.find_by(id: validator.to_h[:product_id])
        if product.nil?
          return render_result(
            success: false,
            data: { code: "product_not_found", message: "Product not found" },
            status: 404
          )
        end

        unless Current.user.client.products.exists?(product.id)
          return render_result(
            success: false,
            data: { code: "forbidden", message: "You do not have access to this product" },
            status: 403
          )
        end

        result = V1::Clients::Cards::CreateService.new(client: Current.user.client, product: product, params: validator.to_h).call

        if result.success?
          render_result(
            success: true,
            data: V1::Clients::Cards::CardSerializer.new(result.data),
            status: 201
          )
        else
          render_result(success: false, data: result.data, status: 422)
        end
      end

      private

      def card_params
        params.permit(:product_id, :pin, purchase_details: {}).to_h
      end
    end
  end
end
