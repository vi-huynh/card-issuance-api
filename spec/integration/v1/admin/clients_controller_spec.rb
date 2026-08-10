# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Admin::Clients', type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:non_admin) { create(:user, role: :client) }
  let(:admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: admin.id)}" } }
  let(:non_admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: non_admin.id)}" } }

  describe 'GET /v1/admin/clients' do
    let!(:clients) do
      create_list(:user, 3, role: :client).map do |user|
        create(:client, user: user)
      end
    end
    let!(:params) { { page: 1, per_page: 10, sort_by: 'name', sort_order: 'asc' } }

    context 'when the user is an admin' do
      it 'returns a list of clients' do
        get '/v1/admin/clients', headers: admin_headers, params: params

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['items'].size).to eq(3)
      end
    end

    context 'when the user is not an admin' do
      it 'returns a 403 forbidden status' do
        get '/v1/admin/clients', headers: non_admin_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /v1/admin/clients' do
    let(:valid_params) { { name: 'Acme Client', email: 'acme@example.com', payout_rate: 15.5 } }

    context 'when the user is an admin' do
      it 'creates a new client' do
        post '/v1/admin/clients', headers: admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['name']).to eq('Acme Client')
      end
    end

    context 'when the user is not an admin' do
      it 'returns a 403 forbidden status' do
        post '/v1/admin/clients', headers: non_admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the email is already taken' do
      let!(:existing_user) { create(:user, email: 'acme@example.com') }

      it 'returns a 422 unprocessable entity status' do
        post '/v1/admin/clients', headers: admin_headers, params: valid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when the payout rate is out of range' do
      let(:invalid_params) { valid_params.merge(payout_rate: 150) }

      it 'returns a 400 bad request status' do
        post '/v1/admin/clients', headers: admin_headers, params: invalid_params, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the name is missing' do
      let(:invalid_params) { valid_params.merge(name: '') }

      it 'returns a 400 bad request status' do
        post '/v1/admin/clients', headers: admin_headers, params: invalid_params, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the email is malformed' do
      let(:invalid_params) { valid_params.merge(email: 'not-an-email') }

      it 'returns a 400 bad request status' do
        post '/v1/admin/clients', headers: admin_headers, params: invalid_params, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
