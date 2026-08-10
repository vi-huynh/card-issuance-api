module V1
  module Admin
    module Clients
      class CreateService < ApplicationService
        INVITE_TOKEN_VALIDITY = 24.hours

        def initialize(
          params: {},
          user_model: User,
          client_model: Client
        )
          super(params:)
          @user_model = user_model
          @client_model = client_model
        end

        def call
          invite_token = SecureRandom.hex(32)

          user = @user_model.new(
            email: client_params[:email],
            password: SecureRandom.hex(16),
            role: :client,
            invite_token: invite_token,
            invite_token_expires_at: INVITE_TOKEN_VALIDITY.from_now,
            invited_at: Time.current
          )

          client = nil

          ActiveRecord::Base.transaction do
            user.save!
            client = user.create_client!(
              name: client_params[:name],
              payout_rate: client_params[:payout_rate],
              status: :pending
            )
          end

          # TODO implement
          # ClientMailer.invite(user, invite_token).deliver_later

          success(data: { client: client, invite_token: invite_token })
        rescue ActiveRecord::RecordInvalid => e
          error(code: "client_not_created", message: "Failed to create client", details: e.record.errors)
        end

        private

        def client_params
          @params.slice(:name, :email, :payout_rate)
        end
      end
    end
  end
end
