module V1
  module Admin
    module ClientProducts
      class ClientProductSerializer < ApplicationSerializer
        attributes :id, :client_id, :product_id, :created_at
      end
    end
  end
end
