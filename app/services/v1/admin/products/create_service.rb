module V1
  module Admin
    module Products
      class CreateService < ApplicationService
        def initialize(
          params: {},
          product_model: Product
        )
          super(params:)
          @product_model = product_model
        end

        def call
          product = @product_model.new(product_params)
          if product.save
            success(data: product)
          else
            error(code: "product_not_created", message: "Failed to create product", details: product.errors)
          end
        end

        private

        def product_params
          @params.slice(:name, :description, :price, :brand_id)
        end
      end
    end
  end
end
