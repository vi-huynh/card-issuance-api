# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Sessions', type: :request do
  describe 'POST /v1/login' do
    let!(:user) { create(:user, email: 'user@example.com', password: 'correct-password') }

    context 'with valid credentials' do
      let(:params) { { email: 'user@example.com', password: 'correct-password' } }

      it 'returns 200 with an access token and the user' do
        post '/v1/login', params: params, as: :json

        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)
        expect(body['data']['access_token']).to be_present
        expect(body['data']['user']).to eq('id' => user.id, 'email' => user.email)
      end
    end

    context 'with an incorrect password' do
      let(:params) { { email: 'user@example.com', password: 'wrong-password' } }

      it 'returns 401 with an invalid_credentials error' do
        post '/v1/login', params: params, as: :json

        expect(response).to have_http_status(:unauthorized)

        body = JSON.parse(response.body)
        expect(body['error']).to eq(
          'code' => 'invalid_credentials',
          'message' => 'Invalid email or password',
          'details' => [ 'invalid credentials' ]
        )
      end
    end

    context 'with an unknown email' do
      let(:params) { { email: 'unknown@example.com', password: 'correct-password' } }

      it 'returns 401 with an invalid_credentials error' do
        post '/v1/login', params: params, as: :json

        expect(response).to have_http_status(:unauthorized)

        body = JSON.parse(response.body)
        expect(body['error']['code']).to eq('invalid_credentials')
      end
    end

    context 'with a malformed email' do
      let(:params) { { email: 'not-an-email', password: 'correct-password' } }

      it 'returns 400 with validation details' do
        post '/v1/login', params: params, as: :json

        expect(response).to have_http_status(:bad_request)

        body = JSON.parse(response.body)
        expect(body['error']['code']).to eq('bad_request')
        expect(body['error']['details']).to have_key('email')
      end
    end

    context 'with a missing password' do
      let(:params) { { email: 'user@example.com' } }

      it 'returns 400 with validation details' do
        post '/v1/login', params: params, as: :json

        expect(response).to have_http_status(:bad_request)

        body = JSON.parse(response.body)
        expect(body['error']['code']).to eq('bad_request')
        expect(body['error']['details']).to have_key('password')
      end
    end
  end
end
