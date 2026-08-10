module V1
  module Clients
    class CardsController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_client!

      CREATE_ERROR_STATUSES = {
        "product_not_found" => 404,
        "forbidden" => 403
      }.freeze

      def create
        validator = V1::Clients::Cards::CreateValidator.new.call(card_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Clients::Cards::CreateService.new(client: Current.user.client, params: validator.to_h).call

        if result.success?
          render_result(
            success: true,
            data: V1::Clients::Cards::CardSerializer.new(result.data),
            status: 201
          )
        else
          render_result(success: false, data: result.data, status: CREATE_ERROR_STATUSES.fetch(result.data[:code], 422))
        end
      end

      def cancel
        card = Card.find_by(id: params[:id], client_id: Current.user.client.id)
        if card.nil?
          return render_result(
            success: false,
            data: { code: "card_not_found", message: "Card not found" },
            status: 404
          )
        end

        result = V1::Clients::Cards::CancelService.new(card: card).call

        if result.success?
          render_result(success: true, data: V1::Clients::Cards::CardSerializer.new(result.data))
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
