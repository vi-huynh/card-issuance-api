module V1
  module Admin
    class BrandsController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_admin!

      def index
        validator = V1::Admin::Brands::IndexValidator.new.call(index_params)
        Rails.logger.debug("Index Validator result: #{validator.inspect}")  # Log the validator result for debugging
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Admin::Brands::IndexService.new(params: validator.to_h).call
        render_result(
          success: result.success?,
          data: {
            items: ActiveModel::Serializer::CollectionSerializer.new(result.data[:items], serializer: V1::Admin::Brands::BrandSerializer),
            pagination: result.data[:pagination]
          }
        )
      end

      def create
        validator = V1::Admin::Brands::CreateValidator.new.call(brand_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Admin::Brands::CreateService.new(params: validator.to_h, current_user: Current.user).call

        if result.success?
          render_result(
            success: true,
            data: V1::Admin::Brands::BrandSerializer.new(result.data),
            status: 201
          )
        else
          render_result(
            success: false,
            data: result.data,
            status: 422
          )
        end
      end

      def show
        brand = Brand.find_by(id: params[:id])
        if brand.nil?
          render_result(
            success: false,
            data: { code: "brand_not_found", message: "Brand not found" },
            status: 404
          )
        else
          render_result(
            success: true,
            data: V1::Admin::Brands::BrandSerializer.new(brand)
          )
        end
      end

      private

      def brand_params
        params.permit(:name, :description, :logo_url, :contact_email).to_h
      end

      def index_params
        params.permit(:page, :per_page, :sort_by, :sort_order).to_h
      end
    end
  end
end
