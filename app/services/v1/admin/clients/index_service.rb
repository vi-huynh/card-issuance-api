# frozen_string_literal: true

module V1
  module Admin
    module Clients
      class IndexService < ApplicationService
        def initialize(
          params: {},
          client_model: Client,
          pagy_service: PagyService.instance
        )
          super(params:)
          @client_model = client_model
          @pagy_service = pagy_service
        end

        def call
          clients_scope = filter_by
          items, pagination = @pagy_service.paginate_with_pagy(clients_scope, pagination_params)

          success(data: { items:, pagination: })
        end

        private

        def pagination_params
          { page: @params[:page], limit: @params[:per_page] }
        end

        def filter_by
          scope = @client_model.all
          scope = scope.order(@params[:sort_by] => @params[:sort_order]) if @params[:sort_by].present? && @params[:sort_order].present?
          scope
        end
      end
    end
  end
end
