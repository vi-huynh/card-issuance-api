# frozen_string_literal: true

module V1
  module Admin
    module Products
      class IndexService < ApplicationService
        def initialize(
          params: {},
          product_model: Product,
          pagy_service: PagyService.instance
        )
          super(params:)
          @product_model = product_model
          @pagy_service = pagy_service
        end

        def call
          products_scope = filter_by
          items, pagination = @pagy_service.paginate_with_pagy(products_scope, pagination_params)

          success(data: { items:, pagination: })
        end

        private

        def pagination_params
          { page: @params[:page], limit: @params[:per_page] }
        end

        def filter_by
          scope = @product_model.all
          scope = scope.where(brand_id: @params[:brand_id]) if @params[:brand_id].present?
          scope = scope.order(@params[:sort_by] => @params[:sort_order]) if @params[:sort_by].present? && @params[:sort_order].present?
          scope
        end
      end
    end
  end
end
