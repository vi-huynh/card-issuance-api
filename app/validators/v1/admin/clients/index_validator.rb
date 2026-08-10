# frozen_string_literal: true

module V1
  module Admin
    module Clients
      class IndexValidator < Dry::Validation::Contract
        params do
          optional(:page).maybe(:integer, gt?: 0)
          optional(:per_page).maybe(:integer, gt?: 0, lteq?: 100)
          optional(:sort_by).maybe(:string, included_in?: Client::SORTABLE_FIELDS)
          optional(:sort_order).maybe(:string, included_in?: Client::SORT_ORDER)
        end
      end
    end
  end
end
