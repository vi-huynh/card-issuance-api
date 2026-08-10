module V1
  module Clients
    module Cards
      class CardSerializer < ApplicationSerializer
        attributes :id, :product_id, :activation_number, :pin, :status, :amount, :current_balance, :currency, :purchase_details, :created_at
      end
    end
  end
end
