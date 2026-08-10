module V1
  module Admin
    class ProductsController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_admin!

      def index
        validator = V1::Admin::Products::IndexValidator.new.call(index_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Admin::Products::IndexService.new(params: validator.to_h).call
        render_result(
          success: result.success?,
          data: {
            items: ActiveModel::Serializer::CollectionSerializer.new(result.data[:items], serializer: V1::Admin::Products::ProductSerializer),
            pagination: result.data[:pagination]
          }
        )
      end

      def create
        validator = V1::Admin::Products::CreateValidator.new.call(product_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Admin::Products::CreateService.new(params: validator.to_h).call

        if result.success?
          render_result(
            success: true,
            data: V1::Admin::Products::ProductSerializer.new(result.data),
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

      def update
        product = Product.find_by(id: params[:id])
        validator = V1::Admin::Products::UpdateValidator.new.call(product_params.merge(id: params[:id]))
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Admin::Products::UpdateService.new(
          product:,
          params: validator.to_h
          ).call
        if result.success?
          render_result(
            success: true,
            data: V1::Admin::Products::ProductSerializer.new(result.data)
          )
        else
          render_result(
            success: false,
            data: result.data,
            status: 422
          )
        end
      end

      def destroy
        product = Product.find_by(id: params[:id])
        if product.nil?
          return render_result(
            success: false,
            data: { code: "product_not_found", message: "Product not found" },
            status: 404
          )
        end

        result = V1::Admin::Products::DestroyService.new(product: product).call
        if result.success?
          render_result(
            success: true,
            data: { message: "Product deleted successfully" }
          )
        else
          render_result(
            success: false,
            data: result.data,
            status: 422
          )
        end
      end

      def show
        product = Product.find_by(id: params[:id])

        if product.nil?
          render_result(
            success: false,
            data: { code: "product_not_found", message: "Product not found" },
            status: 404
          )
        else
          render_result(
            success: true,
            data: V1::Admin::Products::ProductSerializer.new(product)
          )
        end
      end

      private

      def product_params
        params.permit(:name, :description, :price, :brand_id).to_h
      end

      def index_params
        params.permit(:page, :per_page, :sort_by, :sort_order).to_h
      end
    end
  end
end
