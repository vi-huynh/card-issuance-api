# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Admin::Reports', type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:non_admin) { create(:user, role: :client) }
  let(:admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: admin.id)}" } }
  let(:non_admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: non_admin.id)}" } }

  let(:brand) { create(:brand) }
  let(:other_brand) { create(:brand) }
  let(:product) { create(:product, brand: brand) }
  let(:other_product) { create(:product, brand: other_brand) }
  let(:client) { create(:client, user: create(:user, role: :client)) }
  let(:other_client) { create(:client, user: create(:user, role: :client)) }

  let(:date_range) { { date_from: 1.year.ago.to_date, date_to: Date.tomorrow } }

  describe 'GET /v1/admin/report' do
    context 'when the user is not an admin' do
      it 'returns a 403 forbidden status' do
        get '/v1/admin/report', headers: non_admin_headers, params: date_range

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the user is an admin' do
      let!(:issued_card) do
        create(:card, client: client, product: product, status: 0, amount: 10, current_balance: 4)
      end
      let!(:cancelled_card) do
        create(:card, client: client, product: product, status: 1, amount: 20, current_balance: 20)
      end
      let!(:other_brand_card) do
        create(:card, client: other_client, product: other_product, status: 0, amount: 30, current_balance: 30)
      end

      it 'returns totals scoped to the selected brand' do
        get '/v1/admin/report', headers: admin_headers, params: date_range.merge(brand_id: brand.id)

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)['data']
        expect(data.values_at('total_card', 'total_card_issued', 'total_card_cancelled')).to eq([ 2, 1, 1 ])
        expect(data['total_issued_amount'].to_f).to eq(30.0)
        expect(data['total_current_balance'].to_f).to eq(24.0)
        expect(data['total_redeemed'].to_f).to eq(6.0)
      end

      it 'returns totals scoped to the selected client' do
        get '/v1/admin/report', headers: admin_headers, params: date_range.merge(client_id: client.id)

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)['data']
        expect(data.values_at('total_card', 'total_card_issued', 'total_card_cancelled')).to eq([ 2, 1, 1 ])
      end

      it 'returns totals scoped to both brand and client' do
        get '/v1/admin/report', headers: admin_headers, params: date_range.merge(brand_id: brand.id, client_id: client.id)

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)['data']
        expect(data.values_at('total_card', 'total_card_issued', 'total_card_cancelled')).to eq([ 2, 1, 1 ])
      end

      it 'excludes another brand client activity when filtering by brand' do
        get '/v1/admin/report', headers: admin_headers, params: date_range.merge(brand_id: brand.id)

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)['data']
        expect(data['total_card']).to eq(2)
      end

      it 'returns zero-value totals when no cards match the filters' do
        get '/v1/admin/report', headers: admin_headers, params: date_range.merge(brand_id: create(:brand).id)

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)['data']
        expect(data.values_at('total_card', 'total_card_issued', 'total_card_cancelled')).to eq([ 0, 0, 0 ])
        expect(data['total_issued_amount'].to_f).to eq(0.0)
        expect(data['total_current_balance'].to_f).to eq(0.0)
        expect(data['total_redeemed'].to_f).to eq(0.0)
      end

      it 'includes all cards within the date range when no brand/client is given' do
        get '/v1/admin/report', headers: admin_headers, params: date_range

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)['data']
        expect(data['total_card']).to eq(3)
      end
    end

    context 'when date_from is after date_to' do
      it 'returns a 400 bad request status' do
        get '/v1/admin/report', headers: admin_headers, params: { date_from: '2026-02-01', date_to: '2026-01-01' }

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when date_from or date_to is missing' do
      it 'returns a 400 bad request status' do
        get '/v1/admin/report', headers: admin_headers, params: { date_from: '2026-01-01' }

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
