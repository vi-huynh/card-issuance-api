module V1
  module Admin
    module Clients
      class ClientSerializer < ApplicationSerializer
        attributes :id, :name, :payout_rate, :status, :user_id, :invite_token, :created_at, :updated_at

        def invite_token 
          object.user.invite_token
        end
      end
    end
  end
end
