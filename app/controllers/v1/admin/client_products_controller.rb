module V1
  module Admin
    class ClientProductsController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_admin!

      def create
        validator = V1::Admin::ClientProducts::CreateValidator.new.call(client_product_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        client = Client.find_by(id: validator.to_h[:client_id])
        if client.nil?
          return render_result(
            success: false,
            data: { code: "client_not_found", message: "Client not found" },
            status: 404
          )
        end

        result = V1::Admin::ClientProducts::CreateService.new(client: client, params: validator.to_h).call

        if result.success?
          render_result(
            success: true,
            data: V1::Admin::ClientProducts::ClientProductSerializer.new(result.data),
            status: 201
          )
        else
          render_result(success: false, data: result.data, status: 422)
        end
      end

      def destroy
        client_product = ClientProduct.find_by(id: params[:id])
        if client_product.nil?
          return render_result(
            success: false,
            data: { code: "client_product_not_found", message: "Access grant not found" },
            status: 404
          )
        end

        result = V1::Admin::ClientProducts::DestroyService.new(client_product: client_product).call

        if result.success?
          render_result(success: true, data: { message: "Product access revoked successfully" })
        else
          render_result(success: false, data: result.data, status: 422)
        end
      end

      private

      def client_product_params
        params.permit(:client_id, :product_id).to_h
      end
    end
  end
end
