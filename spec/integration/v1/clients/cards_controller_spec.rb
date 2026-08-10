# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Clients::Cards', type: :request do
  let(:client_user) { create(:user, role: :client) }
  let(:client) { create(:client, user: client_user) }
  let(:client_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: client_user.id)}" } }
  let(:admin) { create(:user, role: :admin) }
  let(:admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: admin.id)}" } }
  let(:brand) { create(:brand) }

  describe 'POST /v1/clients/cards' do
    context 'when the client has access to an active product' do
      let!(:product) { create(:product, brand: brand, price: 25, status: :active) }

      before do
        create(:client_product, client: client, product: product)
      end

      it 'issues a card and returns activation number, pin, and purchase details' do
        post '/v1/clients/cards', headers: client_headers, params: { product_id: product.id }, as: :json

        expect(response).to have_http_status(:created)
        data = JSON.parse(response.body)['data']
        expect(data['activation_number']).to be_present
        expect(data['pin']).to be_present
        expect(data['status']).to eq('issued')
        expect(data['purchase_details']).to eq({})
      end

      it 'returns a 403 forbidden status for a non-client (e.g. an admin)' do
        post '/v1/clients/cards', headers: admin_headers, params: { product_id: product.id }, as: :json

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns a 400 bad request status when product_id is missing' do
        post '/v1/clients/cards', headers: client_headers, params: {}, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the client does not have access to the product' do
      let!(:product) { create(:product, brand: brand, price: 25, status: :active) }

      it 'returns a 403 forbidden status' do
        client

        post '/v1/clients/cards', headers: client_headers, params: { product_id: product.id }, as: :json

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the product is inactive' do
      let!(:product) { create(:product, brand: brand, price: 25, status: :inactive) }

      before do
        create(:client_product, client: client, product: product)
      end

      it 'returns a 422 unprocessable entity status reporting the product is not available' do
        post '/v1/clients/cards', headers: client_headers, params: { product_id: product.id }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)['error']['code']).to eq('product_not_available')
      end
    end

    context 'when the product does not exist' do
      it 'returns a 404 not found status' do
        client

        post '/v1/clients/cards', headers: client_headers, params: { product_id: 999_999 }, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
