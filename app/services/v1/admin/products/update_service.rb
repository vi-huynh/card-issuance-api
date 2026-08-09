module V1
  module Admin
    module Products
      class UpdateService < ApplicationService
        def initialize(
          product:,
          params: {},
          product_model: Product
        )
          super(params:)
          @product = product
          @product_model = product_model
        end

        def call
          do_validation

          if @errors.any?
            return error(
              code: "product_not_updated",
              message: "Failed to update product",
              details: @errors
            )
          end

          if @product.update(product_params)
            success(data: @product)
          else
            error(
              code: "product_not_updated",
              message: "Failed to update product",
              details: @product.errors
            )
          end
        end

        private

        def do_validation
          @errors = []
          @errors << "Product not found" if @product.nil?
          @errors << "Product name is ready exists" if product_model.where(name: @product).where.not(id: @product.id).exists?
        end

        def product_params
          @params.slice(:name, :description, :price, :brand_id)
        end
      end
    end
  end
end
