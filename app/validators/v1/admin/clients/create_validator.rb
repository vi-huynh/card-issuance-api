# frozen_string_literal: true

module V1
  module Admin
    module Clients
      class CreateValidator < Dry::Validation::Contract
        params do
          required(:name).filled(:string, max_size?: 255)
          required(:email).filled(:string, max_size?: 255)
          required(:payout_rate).filled(:float, gteq?: 0, lteq?: 100)
        end

        rule(:email) do
          key.failure("is invalid") if value.present? && value !~ URI::MailTo::EMAIL_REGEXP
        end
      end
    end
  end
end
