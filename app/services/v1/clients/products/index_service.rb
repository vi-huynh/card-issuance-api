# frozen_string_literal: true

module V1
  module Clients
    module Products
      class IndexService < ApplicationService
        def initialize(
          client:,
          params: {},
          pagy_service: PagyService.instance
        )
          super(params:)
          @client = client
          @pagy_service = pagy_service
        end

        def call
          items, pagination = @pagy_service.paginate_with_pagy(filter_by, pagination_params)

          success(data: { items:, pagination: })
        end

        private

        def pagination_params
          { page: @params[:page], limit: @params[:per_page] }
        end

        def filter_by
          scope = @client.accessible_products.includes(:brand)
          scope = scope.where(status: @params[:status]) if @params[:status].present?
          scope = scope.where("products.name ILIKE ?", "%#{@params[:name]}%") if @params[:name].present?
          scope = scope.joins(:brand).where("brands.name ILIKE ?", "%#{@params[:brand_name]}%") if @params[:brand_name].present?
          scope = scope.where("products.price >= ?", @params[:min_price]) if @params[:min_price].present?
          scope = scope.where("products.price <= ?", @params[:max_price]) if @params[:max_price].present?
          scope = scope.order(@params[:sort_by] => @params[:sort_order]) if @params[:sort_by].present? && @params[:sort_order].present?
          scope
        end
      end
    end
  end
end
