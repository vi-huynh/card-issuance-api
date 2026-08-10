# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Clients::PasswordResets', type: :request do
  describe 'POST /v1/clients/password_reset' do
    let(:invite_token) { 'valid-invite-token' }
    let!(:user) do
      create(
        :user,
        role: :client,
        invite_token: invite_token,
        invite_token_expires_at: 24.hours.from_now
      )
    end

    let!(:client) do
    create(
      :client,
      user_id: user.id,
      name: "Client name",
      status: :pending
    )
  end

    context 'when the invite token is valid' do
      let(:valid_params) { { invite_token: invite_token, password: 'newpassword123', password_confirmation: 'newpassword123' } }

      it 'sets the password and returns 200 ok' do
        post '/v1/clients/password_reset', params: valid_params, as: :json

        expect(response).to have_http_status(:ok)
        expect(user.reload.authenticate('newpassword123')).to eq(user)
      end
    end

    context 'when the invite token does not match any user' do
      let(:invalid_params) { { invite_token: 'bogus-token', password: 'newpassword123' } }

      it 'returns a 422 unprocessable entity status' do
        post '/v1/clients/password_reset', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when the invite token has expired' do
      let!(:user) do
        create(
          :user,
          role: :client,
          invite_token: invite_token,
          invite_token_expires_at: 1.hour.ago
        )
      end
      let(:params) { { invite_token: invite_token, password: 'newpassword123' } }

      it 'returns a 422 unprocessable entity status' do
        post '/v1/clients/password_reset', params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when the password is too short' do
      let(:invalid_params) { { invite_token: invite_token, password: 'short' } }

      it 'returns a 400 bad request status' do
        post '/v1/clients/password_reset', params: invalid_params, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the invite token is missing' do
      let(:invalid_params) { { password: 'newpassword123' } }

      it 'returns a 400 bad request status' do
        post '/v1/clients/password_reset', params: invalid_params, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
