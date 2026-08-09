# frozen_string_literal: true

module V1
  module Admin
    module Products
      class UpdateValidator < Dry::Validation::Contract
        params do
          required(:name).filled(:string, max_size?: 255)
          optional(:description).maybe(:string)
          optional(:price).maybe(:float, gt?: 0)
          required(:brand_id).filled(:integer, gt?: 0)
        end
      end
    end
  end
end
