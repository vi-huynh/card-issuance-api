# frozen_string_literal: true

module V1
  module Admin
    module Brands
      class IndexService < ApplicationService
        def initialize(
          params: {},
          brand_model: Brand,
          pagy_service: PagyService.instance
        )
          super(params:)
          @brand_model = brand_model
          @pagy_service = pagy_service
        end

        def call
          brands_scope = filter_by
          items, pagination = @pagy_service.paginate_with_pagy(brands_scope, pagination_params)

          success(data: { items:, pagination: })
        end

        private

        def pagination_params
          { page: @params[:page], limit: @params[:per_page] }
        end

        def filter_by
          scope = @brand_model.all
          scope = scope.order(@params[:sort_by] => @params[:sort_order]) if @params[:sort_by].present? && @params[:sort_order].present?
          scope
        end
      end
    end
  end
end
