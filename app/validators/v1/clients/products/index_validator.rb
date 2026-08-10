# frozen_string_literal: true

module V1
  module Clients
    module Products
      class IndexValidator < Dry::Validation::Contract
        params do
          optional(:page).maybe(:integer, gt?: 0)
          optional(:per_page).maybe(:integer, gt?: 0, lteq?: 100)
          optional(:sort_by).maybe(:string, included_in?: Product::SORTABLE_FIELDS)
          optional(:sort_order).maybe(:string, included_in?: Product::SORT_ORDER)
          optional(:brand_name).maybe(:string)
          optional(:name).maybe(:string)
          optional(:min_price).maybe(:float, gteq?: 0)
          optional(:max_price).maybe(:float, gteq?: 0)
          optional(:status).maybe(:string, included_in?: Product.statuses.keys)
        end

        rule(:min_price, :max_price) do
          if values[:min_price].present? && values[:max_price].present? && values[:min_price] > values[:max_price]
            key(:min_price).failure("must be less than or equal to max_price")
          end
        end
      end
    end
  end
end
