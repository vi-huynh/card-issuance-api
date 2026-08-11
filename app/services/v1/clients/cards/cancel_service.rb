# frozen_string_literal: true

module V1
  module Clients
    module Cards
      class CancelService < ApplicationService
        def initialize(
          card:
        )
          super()
          @card = card
        end

        def call
          return already_cancelled_error if @card.cancelled?

          if @card.update(status: :cancelled)
            success(data: @card)
          else
            error(code: "card_not_cancelled", message: "Failed to cancel card", details: @card.errors)
          end
        end

        private

        def already_cancelled_error
          error(code: "card_already_cancelled", message: "Card is already cancelled", details: [])
        end
      end
    end
  end
end
