# frozen_string_literal: true

module V1
  module Admin
    module ClientProducts
      class CreateService < ApplicationService
        def initialize(
          client:,
          params: {}
        )
          super(params:)
          @client = client
        end

        def call
          client_product = @client.client_products.new(product_id: @params[:product_id])

          if client_product.save
            success(data: client_product)
          else
            error(code: "client_product_not_created", message: "Failed to grant product access", details: client_product.errors)
          end
        end
      end
    end
  end
end
