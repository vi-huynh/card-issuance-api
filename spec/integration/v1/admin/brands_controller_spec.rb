# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Admin::Brands', type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:non_admin) { create(:user, role: :user) }
  let(:admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: admin.id)}" } }
  let(:non_admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: non_admin.id)}" } }

  describe 'GET /v1/admin/brands' do
    let!(:brands) { create_list(:brand, 3) }
    let!(:params) { { page: 1, per_page: 10, sort_by: 'name', sort_order: 'asc' } }

    context 'when the user is an admin' do
      it 'returns a list of brands' do
        get '/v1/admin/brands', headers: admin_headers, params: params
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['items'].size).to eq(3)
      end
    end

    context 'when the user is not an admin' do
      it 'returns a 403 forbidden status' do
        get '/v1/admin/brands', headers: non_admin_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /v1/admin/brands' do
    let(:valid_params) {  { name: 'New Brand', description: 'A new brand', logo_url: 'http://example.com/logo.png', contact_email: 'contact@example.com' } }

    context 'when the user is an admin' do
      it 'creates a new brand' do
        post '/v1/admin/brands', headers: admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:created)
      end
    end

    context 'when the user is not an admin' do
      it 'returns a 403 forbidden status' do
        post '/v1/admin/brands', headers: non_admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the brand name is already taken' do
      let!(:existing_brand) { create(:brand, name: 'Existing Brand') }
      let(:invalid_params) { { name: 'Existing Brand', description: 'A new brand', logo_url: 'http://example.com/logo.png', contact_email: 'contact@example.com' } }

      it 'returns a 422 unprocessable entity status' do
        post '/v1/admin/brands', headers: admin_headers, params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the contact email is invalid' do
      let(:invalid_params) { { name: 'New Brand', description: 'A new brand', logo_url: 'http://example.com/logo.png', contact_email: 'invalid-email' } }

      it 'returns a 400 bad request status' do
        post '/v1/admin/brands', headers: admin_headers, params: invalid_params, as: :json
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
