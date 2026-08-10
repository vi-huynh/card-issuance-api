# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Admin::Products', type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:non_admin) { create(:user, role: :client) }
  let(:admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: admin.id)}" } }
  let(:non_admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: non_admin.id)}" } }
  let(:brand) { create(:brand) }

  describe 'GET /v1/admin/brands/:brand_id/products' do
    let!(:products) { create_list(:product, 3, brand: brand) }
    let!(:params) { { page: 1, per_page: 10, sort_by: 'name', sort_order: 'asc' } }

    context 'when the user is an admin' do
      it 'returns a list of products' do
        get "/v1/admin/brands/#{brand.id}/products", headers: admin_headers, params: params

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['items'].size).to eq(3)
      end
    end

    context 'when the user is not an admin' do
      it 'returns a 403 forbidden status' do
        get "/v1/admin/brands/#{brand.id}/products", headers: non_admin_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /v1/admin/brands/:brand_id/products/:id' do
    let!(:product) { create(:product, brand: brand) }

    context 'when the user is an admin and the product exists' do
      it 'returns the product' do
        get "/v1/admin/brands/#{brand.id}/products/#{product.id}", headers: admin_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['id']).to eq(product.id)
      end
    end

    context 'when the user is not an admin' do
      it 'returns a 403 forbidden status' do
        get "/v1/admin/brands/#{brand.id}/products/#{product.id}", headers: non_admin_headers

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the product does not exist' do
      it 'returns a 404 not found status' do
        get "/v1/admin/brands/#{brand.id}/products/0", headers: admin_headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /v1/admin/brands/:brand_id/products' do
    let(:valid_params) { { name: 'New Product', description: 'A new product', price: 9.99, brand_id: brand.id } }

    context 'when the user is an admin' do
      it 'creates a new product' do
        post "/v1/admin/brands/#{brand.id}/products", headers: admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:created)
      end
    end

    context 'when the user is not an admin' do
      it 'returns a 403 forbidden status' do
        post "/v1/admin/brands/#{brand.id}/products", headers: non_admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the brand does not exist' do
      it 'returns a 422 unprocessable entity status' do
        post "/v1/admin/brands/#{brand.id + 999_999}/products", headers: admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when the name is missing' do
      let(:invalid_params) { valid_params.merge(name: '') }

      it 'returns a 400 bad request status' do
        post "/v1/admin/brands/#{brand.id}/products", headers: admin_headers, params: invalid_params, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'PATCH /v1/admin/brands/:brand_id/products/:id' do
    let!(:product) { create(:product, brand: brand, name: 'Original name', price: 5) }
    let(:valid_params) { { name: 'Updated name', description: 'Updated description', price: 19.99, brand_id: brand.id } }

    context 'when the user is an admin' do
      it 'updates the product' do
        patch "/v1/admin/brands/#{brand.id}/products/#{product.id}", headers: admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['name']).to eq('Updated name')
      end
    end

    context 'when the user is not an admin' do
      it 'returns a 403 forbidden status' do
        patch "/v1/admin/brands/#{brand.id}/products/#{product.id}", headers: non_admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the new name is already taken by another product' do
      let!(:other_product) { create(:product, brand: brand, name: 'Taken name') }
      let(:invalid_params) { valid_params.merge(name: 'Taken name') }

      it 'returns a 422 unprocessable entity status' do
        patch "/v1/admin/brands/#{brand.id}/products/#{product.id}", headers: admin_headers, params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when the name is missing' do
      let(:invalid_params) { valid_params.merge(name: '') }

      it 'returns a 400 bad request status' do
        patch "/v1/admin/brands/#{brand.id}/products/#{product.id}", headers: admin_headers, params: invalid_params, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'DELETE /v1/admin/brands/:brand_id/products/:id' do
    let!(:product) { create(:product, brand: brand) }

    context 'when the user is an admin and the product has no issued cards' do
      it 'deletes the product' do
        delete "/v1/admin/brands/#{brand.id}/products/#{product.id}", headers: admin_headers

        expect(response).to have_http_status(:ok)
        expect(Product.exists?(product.id)).to eq(false)
      end
    end

    context 'when the user is not an admin' do
      it 'returns a 403 forbidden status' do
        delete "/v1/admin/brands/#{brand.id}/products/#{product.id}", headers: non_admin_headers

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the product does not exist' do
      it 'returns a 404 not found status' do
        delete "/v1/admin/brands/#{brand.id}/products/0", headers: admin_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the product has an issued card' do
      let!(:client) { Client.create!(user: create(:user), name: 'Client name', payout_rate: 1, status: :active) }
      let!(:card) do
        Card.create!(
          client: client,
          product: product,
          activation_number: 'AN-000001',
          status: 0,
          amount: 10,
          current_balance: 10,
          currency: 'USD'
        )
      end

      it 'returns a 422 unprocessable entity status' do
        delete "/v1/admin/brands/#{brand.id}/products/#{product.id}", headers: admin_headers

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
