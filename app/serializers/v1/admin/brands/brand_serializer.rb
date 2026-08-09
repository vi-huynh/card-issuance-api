module V1
  module Admin
    module Brands
      class BrandSerializer < ApplicationSerializer
        attributes :id, :name, :description, :logo_url, :contact_email, :created_at, :updated_at
      end
    end
  end
end
