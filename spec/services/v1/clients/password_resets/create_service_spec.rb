# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Clients::PasswordResets::CreateService do
  subject(:result) { service.call }

  let(:service) { described_class.new(params: params) }
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

  describe 'when the invite token is valid and not expired' do
    let(:params) { { invite_token: invite_token, password: 'newpassword123', password_confirmation: 'newpassword123' } }

    it 'sets the new password' do
      result

      user.reload
      expect(user.authenticate('newpassword123')).to eq(user)
    end

    it 'records invite_accepted_at and clears the invite token and update clien status to active' do
      result

      user.reload
      expect(user.invite_accepted_at).to be_within(1.minute).of(Time.current)
      expect(user.invite_token).to be_nil
      expect(user.invite_token_expires_at).to be_nil
      expect(user.client.status).to eq('active')
    end

    it 'returns a successful result' do
      expect(result.success?).to eq(true)
      expect(result.data[:message]).to eq('Password set successfully')
    end
  end

  describe 'when the invite token does not match any user' do
    let(:params) { { invite_token: 'bogus-token', password: 'newpassword123' } }

    it 'does not change the password of any existing user' do
      expect { result }.not_to change { user.reload.password_digest }
    end

    it 'returns a failure result reporting an invalid token' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('invalid_invite_token')
    end
  end

  describe 'when the invite token has expired' do
    let!(:user) do
      create(
        :user,
        role: :client,
        invite_token: invite_token,
        invite_token_expires_at: 1.hour.ago
      )
    end
    let(:params) { { invite_token: invite_token, password: 'newpassword123' } }

    it 'does not change the password' do
      expect { result }.not_to change { user.reload.password_digest }
    end

    it 'does not clear the invite token' do
      expect { result }.not_to change { user.reload.invite_token }
    end

    it 'returns a failure result reporting the token has expired' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('invite_token_expired')
    end
  end

  describe 'when the password confirmation does not match' do
    let(:params) { { invite_token: invite_token, password: 'newpassword123', password_confirmation: 'mismatch' } }

    it 'does not change the password' do
      expect { result }.not_to change { user.reload.password_digest }
    end

    it 'does not clear the invite token' do
      expect { result }.not_to change { user.reload.invite_token }
    end

    it 'returns a failure result reporting the mismatch' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('password_not_reset')
      expect(result.data[:details][:password_confirmation]).to include("doesn't match Password")
    end
  end
end
