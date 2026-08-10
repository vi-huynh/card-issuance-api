# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Admin::ClientProducts', type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:non_admin) { create(:user, role: :client) }
  let(:admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: admin.id)}" } }
  let(:non_admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: non_admin.id)}" } }
  let(:brand) { create(:brand) }
  let(:product) { create(:product, brand: brand, status: :active) }
  let(:client) { create(:client, user: create(:user, role: :client)) }

  describe 'POST /v1/admin/client_products' do
    let(:valid_params) { { client_id: client.id, product_id: product.id } }

    context 'when the user is an admin' do
      it 'grants the client access to the product' do
        post '/v1/admin/client_products', headers: admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['product_id']).to eq(product.id)
      end
    end

    context 'when the user is not an admin' do
      it 'returns a 403 forbidden status' do
        post '/v1/admin/client_products', headers: non_admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the client does not exist' do
      let(:invalid_params) { valid_params.merge(client_id: client.id + 999_999) }

      it 'returns a 404 not found status' do
        post '/v1/admin/client_products', headers: admin_headers, params: invalid_params, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the client already has access to the product' do
      let!(:existing_grant) { create(:client_product, client: client, product: product) }

      it 'returns a 422 unprocessable entity status' do
        post '/v1/admin/client_products', headers: admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when the product_id is missing' do
      let(:invalid_params) { { client_id: client.id } }

      it 'returns a 400 bad request status' do
        post '/v1/admin/client_products', headers: admin_headers, params: invalid_params, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'DELETE /v1/admin/client_products/:id' do
    let!(:client_product) { create(:client_product, client: client, product: product) }

    context 'when the user is an admin and the grant exists' do
      it 'revokes access' do
        delete "/v1/admin/client_products/#{client_product.id}", headers: admin_headers

        expect(response).to have_http_status(:ok)
        expect(ClientProduct.exists?(client_product.id)).to eq(false)
      end
    end

    context 'when the user is not an admin' do
      it 'returns a 403 forbidden status' do
        delete "/v1/admin/client_products/#{client_product.id}", headers: non_admin_headers

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the grant does not exist' do
      it 'returns a 404 not found status' do
        delete '/v1/admin/client_products/0', headers: admin_headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
