module V1
  module Admin
    module Products
      class DestroyService < ApplicationService
        def initialize(
          product: nil
        )
          super(params:)
          @product = product
        end

        def call
          do_validation

          if @errors.any?
            return error(
              code: "product_not_destroyed",
              message: "Failed to destroy product",
              details: @errors
            )
          end

          if @product.destroy
            success(data: product)
          else
            error(
              code: "product_not_destroyed",
              message: "Failed to destroy product",
              details: product.errors
            )
          end
        end

        private

        def do_validation
          @errors = []
          @errors << "Product not found" if @product.nil?
          @errors << "Product is in use" if @product.clients.exists?
        end
      end
    end
  end
end
