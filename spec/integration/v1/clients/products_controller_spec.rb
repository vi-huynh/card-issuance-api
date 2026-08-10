# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Clients::Products', type: :request do
  let(:client_user) { create(:user, role: :client) }
  let(:client) { create(:client, user: client_user) }
  let(:client_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: client_user.id)}" } }
  let(:admin) { create(:user, role: :admin) }
  let(:admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: admin.id)}" } }

  describe 'GET /v1/clients/products' do
    let(:brand) { create(:brand) }

    context 'when the user is a client with an accessible product' do
      let!(:accessible_product) { create(:product, brand: brand, name: 'Accessible', price: 10, status: :active) }

      before do
        create(:client_product, client: client, product: accessible_product)
      end

      it 'returns their accessible active catalog' do
        get '/v1/clients/products', headers: client_headers

        expect(response).to have_http_status(:ok)
        items = JSON.parse(response.body)['data']['items']
        expect(items.map { |item| item['id'] }).to eq([ accessible_product.id ])
      end

      it 'returns a 403 forbidden status for a non-client (e.g. an admin)' do
        get '/v1/clients/products', headers: admin_headers

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns a 400 bad request status for an invalid price range' do
        get '/v1/clients/products', headers: client_headers, params: { min_price: 100, max_price: 10 }

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the client has no access to any active products' do
      it 'returns an empty result set, not an error', openapi: false do
        client

        get '/v1/clients/products', headers: client_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['items']).to eq([])
      end
    end
  end
end
