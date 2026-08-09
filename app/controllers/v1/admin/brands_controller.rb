module V1
  module Admin
    class BrandsController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_admin!

      def index
        validator = V1::Admin::Brands::IndexValidator.new.call(index_params)
        if validator.failure?
          return bad_request_response(validator.errors)
        end

        result = V1::Admin::Brands::IndexService.new(params: validator.to_h).call
        render_result(
          success: result.success?,
          data: {
            items: result.data[:items].map { |brand| BrandSerializer.new(brand) },
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
            data: BrandSerializer.new(result.data),
            status: 201
          )
        else
          render_result(
            success: false,
            data: result.errors,
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
            data: BrandSerializer.new(brand)
          )
        end
      end

      private

      def brand_params
        params.require(:brand).permit(:name, :description, :logo_url, :contact_email).to_h
      end

      def index_params
        params.permit(:page, :per_page, :sort_by, :sort_order).to_h
      end
    end
  end
end
