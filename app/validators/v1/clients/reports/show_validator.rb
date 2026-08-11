# frozen_string_literal: true

module V1
  module Clients
    module Reports
      class ShowValidator < Dry::Validation::Contract
        params do
          required(:date_from).filled(:date)
          required(:date_to).filled(:date)
        end

        rule(:date_from, :date_to) do
          if values[:date_from].present? && values[:date_to].present? && values[:date_from] > values[:date_to]
            key(:date_from).failure("must be before or equal to date_to")
          end
        end
      end
    end
  end
end
