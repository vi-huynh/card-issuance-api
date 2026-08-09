module V1
  module Admin
    module Brands
      class CreateService < ApplicationService
        def initialize(
          params: {},
          current_user: nil,
          brand_model: Brand,
          audit_log_model: AuditLog
        )
          super(params:)
          @current_user = current_user
          @brand_model = brand_model
          @audit_log_model = audit_log_model
        end

        def call
          brand = @brand_model.new(brand_params)
          if brand.save
            success(data: brand)
          else
            error(code: "brand_not_created", message: "Failed to create brand", details: brand.errors)
          end
        end

        private

        def brand_params
          @params.slice(:name, :description, :logo_url, :contact_email)
        end
      end
    end
  end
end
