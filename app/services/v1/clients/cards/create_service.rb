# frozen_string_literal: true

module V1
  module Clients
    module Cards
      class CreateService < ApplicationService
        def initialize(
          client:,
          product:,
          params: {},
          card_model: Card,
          pin_service: PinService
        )
          super(params:)
          @client = client
          @product = product
          @card_model = card_model
          @pin_service = pin_service
        end

        def call
          return product_not_available_error unless @product.active?

          card = @client.cards.new(card_attributes)

          if card.save
            card.pin = pin
            success(data: card)
          else
            error(code: "card_not_issued", message: "Failed to issue card", details: card.errors)
          end
        end

        private

        def card_attributes
          {
            product: @product,
            activation_number: generate_activation_number,
            pin_digest: @pin_service.hashed_pin(pin),
            status: :issued,
            amount: @product.price,
            current_balance: @product.price,
            purchase_details: @params[:purchase_details] || {}
          }
        end

        def pin
          @pin ||= @pin_service.generate
        end

        def generate_activation_number
          loop do
            candidate = SecureRandom.hex(8).upcase
            break candidate unless @card_model.exists?(activation_number: candidate)
          end
        end

        def product_not_available_error
          error(code: "product_not_available", message: "Product is not available", details: [])
        end
      end
    end
  end
end
