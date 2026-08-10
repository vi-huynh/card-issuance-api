module V1
  module Admin
    module Products
      class DestroyService < ApplicationService
        def initialize(
          product: nil,
          card_model: Card
        )
          super()
          @product = product
          @card_model = card_model
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
            success(data: @product)
          else
            error(
              code: "product_not_destroyed",
              message: "Failed to destroy product",
              details: @product.errors
            )
          end
        end

        private

        def do_validation
          @errors = []

          if @product.nil?
            @errors << "Product not found"
            return
          end

          @errors << "Product is in use" if @card_model.where(product_id: @product.id).exists?
        end
      end
    end
  end
end
