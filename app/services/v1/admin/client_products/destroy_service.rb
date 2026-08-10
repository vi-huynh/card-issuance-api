# frozen_string_literal: true

module V1
  module Admin
    module ClientProducts
      class DestroyService < ApplicationService
        def initialize(
          client_product:
        )
          super()
          @client_product = client_product
        end

        def call
          if @client_product.destroy
            success(data: @client_product)
          else
            error(code: "client_product_not_destroyed", message: "Failed to revoke product access", details: @client_product.errors)
          end
        end
      end
    end
  end
end
