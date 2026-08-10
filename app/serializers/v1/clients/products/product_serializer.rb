module V1
  module Clients
    module Products
      class ProductSerializer < ApplicationSerializer
        attributes :id, :name, :description, :price, :status, :brand_id, :brand_name, :created_at, :updated_at

        def brand_name
          object.brand.name
        end
      end
    end
  end
end
