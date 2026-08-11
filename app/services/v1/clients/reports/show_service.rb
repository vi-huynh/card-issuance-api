# frozen_string_literal: true

module V1
  module Clients
    module Reports
      class ShowService < ApplicationService
        def initialize(client:, params: {}, connection: ActiveRecord::Base.connection)
          super(params:)
          @client = client
          @connection = connection
        end

        def call
          success(data: build_metrics(@connection.select_one(sanitized_sql)))
        end

        private

        def sanitized_sql
          sql = <<~SQL
            SELECT
              COUNT(*) AS total,
              COUNT(*) FILTER (WHERE cards.status = 0) AS issued,
              COUNT(*) FILTER (WHERE cards.status = 1) AS cancelled,
              COALESCE(SUM(cards.amount), 0) AS total_issued_amount,
              COALESCE(SUM(cards.current_balance), 0) AS total_current_balance
            FROM cards
            WHERE cards.client_id = :client_id
            AND cards.created_at BETWEEN :date_from AND :date_to
          SQL

          ActiveRecord::Base.sanitize_sql_array([
            sql,
            client_id: @client.id,
            date_from: @params[:date_from].beginning_of_day,
            date_to: @params[:date_to].end_of_day
          ])
        end

        def build_metrics(row)
          total_issued_amount = row["total_issued_amount"].to_d
          total_current_balance = row["total_current_balance"].to_d

          {
            total_card: row["total"].to_i,
            total_card_issued: row["issued"].to_i,
            total_card_cancelled: row["cancelled"].to_i,
            total_issued_amount: total_issued_amount,
            total_current_balance: total_current_balance,
            total_redeemed: total_issued_amount - total_current_balance
          }
        end
      end
    end
  end
end
