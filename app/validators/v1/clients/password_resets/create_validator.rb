# frozen_string_literal: true

module V1
  module Clients
    module PasswordResets
      class CreateValidator < Dry::Validation::Contract
        params do
          required(:invite_token).filled(:string)
          required(:password).filled(:string, min_size?: 8)
          optional(:password_confirmation).maybe(:string)
        end
      end
    end
  end
end
