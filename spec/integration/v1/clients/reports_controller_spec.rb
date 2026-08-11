# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Clients::Reports', type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:client_user) { create(:user, email: "client-1@example.com", role: :client) }
  let(:other_client_user) { create(:user, email: "client-2@example.com", role: :client) }
  let(:admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: admin.id)}" } }
  let(:client_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: client_user.id)}" } }

  let(:brand) { create(:brand, name: "Brand name 1") }
  let(:product) { create(:product, brand: brand, name: "Product name 1") }
  let(:client) { create(:client, user: client_user) }
  let(:other_client) { create(:client, user: other_client_user) }

  let(:date_range) { { date_from: 1.year.ago.to_date, date_to: Date.tomorrow } }

  describe 'GET /v1/clients/report' do
    context 'when the user is not a client' do
      it 'returns a 403 forbidden status' do
        get '/v1/clients/report', headers: admin_headers, params: date_range

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the user is a client' do
      let!(:issued_card) do
        create(:card, client: client, product: product, status: 0, amount: 10, current_balance: 4)
      end
      let!(:cancelled_card) do
        create(:card, client: client, product: product, status: 1, amount: 20, current_balance: 20)
      end
      let!(:other_client_card) do
        create(:card, client: other_client, product: product, status: 0, amount: 30, current_balance: 30)
      end

      it 'returns totals scoped to the authenticated client only' do
        get '/v1/clients/report', headers: client_headers, params: date_range

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)['data']
        expect(data.values_at('total_card', 'total_card_issued', 'total_card_cancelled')).to eq([ 2, 1, 1 ])
        expect(data['total_issued_amount'].to_f).to eq(30.0)
        expect(data['total_current_balance'].to_f).to eq(24.0)
        expect(data['total_redeemed'].to_f).to eq(6.0)
      end

      it 'excludes other clients\' cards' do
        get '/v1/clients/report', headers: client_headers, params: date_range

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)['data']
        expect(data['total_card']).not_to eq(3)
      end

      it 'returns zero-value totals when the client has no activity in the date range' do
        get '/v1/clients/report', headers: client_headers, params: { date_from: 10.years.ago.to_date, date_to: 5.years.ago.to_date }

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)['data']
        expect(data.values_at('total_card', 'total_card_issued', 'total_card_cancelled')).to eq([ 0, 0, 0 ])
        expect(data['total_issued_amount'].to_f).to eq(0.0)
        expect(data['total_current_balance'].to_f).to eq(0.0)
        expect(data['total_redeemed'].to_f).to eq(0.0)
      end
    end

    context 'when date_from is after date_to' do
      it 'returns a 400 bad request status' do
        get '/v1/clients/report', headers: client_headers, params: { date_from: '2026-02-01', date_to: '2026-01-01' }

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when date_from or date_to is missing' do
      it 'returns a 400 bad request status' do
        get '/v1/clients/report', headers: client_headers, params: { date_from: '2026-01-01' }

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
