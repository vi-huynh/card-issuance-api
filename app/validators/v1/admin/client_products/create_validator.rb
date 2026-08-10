# frozen_string_literal: true

module V1
  module Admin
    module ClientProducts
      class CreateValidator < Dry::Validation::Contract
        params do
          required(:client_id).filled(:integer, gt?: 0)
          required(:product_id).filled(:integer, gt?: 0)
        end
      end
    end
  end
end
