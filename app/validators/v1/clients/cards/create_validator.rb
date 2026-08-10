# frozen_string_literal: true

module V1
  module Clients
    module Cards
      class CreateValidator < Dry::Validation::Contract
        params do
          required(:product_id).filled(:integer, gt?: 0)
          optional(:pin).maybe(:string)
          optional(:purchase_details).maybe(:hash)
        end
      end
    end
  end
end
