# frozen_string_literal: true

module V1
  module Admin
    module Brands
      class CreateValidator < Dry::Validation::Contract
        params do
          required(:name) do
            str? & filled? & max_size?(255)
          end
          optional(:description).maybe(:string)
          optional(:logo_url).maybe(:string)
          optional(:contact_email).maybe(:string)
        end

        rule(:contact_email) do
          if value.present? && value !~ URI::MailTo::EMAIL_REGEXP
            key.failure("is in invalid format")
          end
        end
      end
    end
  end
end
