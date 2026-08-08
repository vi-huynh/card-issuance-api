# frozen_string_literal: true

module V1
  module Sessions
    class CreateValidator < Dry::Validation::Contract
      params do
        required(:email) do
          str? & format?(URI::MailTo::EMAIL_REGEXP) & max_size?(255)
        end
        required(:password).filled(:string)
      end
    end
  end
end
