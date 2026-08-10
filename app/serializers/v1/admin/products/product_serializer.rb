module V1
  module Admin
    module Products
      class ProductSerializer < ApplicationSerializer
        attributes :id, :name, :description, :price, :status, :brand_id, :created_at, :updated_at
      end
    end
  end
end
