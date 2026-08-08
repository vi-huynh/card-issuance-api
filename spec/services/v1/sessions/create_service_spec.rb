# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Sessions::CreateService do
  subject(:result) { service.call }

  let(:service) { described_class.new(params: params) }

  let!(:user) { create(:user, email: 'user@example.com', password: 'correct-password') }

  context 'when the email and password are valid' do
    let(:params) { { email: 'user@example.com', password: 'correct-password' } }

    it 'returns a successful result with an access token and the user' do
      expect(result.success?).to eq(true)
      expect(result.data[:access_token]).to be_present
      expect(result.data[:user]).to eq(id: user.id, email: user.email)
    end

    it 'returns an access token that decodes back to the user id' do
      access_token = result.data[:access_token]

      expect(JwtService.decode(access_token)).to eq('user_id' => user.id)
    end

    it 'persists a login_success audit log tied to the user' do
      expect { result }.to change(AuditLog, :count).by(1)

      audit_log = AuditLog.last
      expect(audit_log.user_id).to eq(user.id)
      expect(audit_log.auditable).to eq(user)
      expect(audit_log).to be_action_login_success
    end
  end

  context 'when no user exists for the given email' do
    let(:params) { { email: 'unknown@example.com', password: 'correct-password' } }

    it 'returns an unauthorized error result' do
      expect(result.success?).to eq(false)
      expect(result.data).to eq(
        code: 'invalid_credentials',
        message: 'Invalid email or password',
        details: [ 'invalid credentials' ]
      )
    end

    it 'persists a login_failed audit log with no associated user' do
      expect { result }.to change(AuditLog, :count).by(1)

      audit_log = AuditLog.last
      expect(audit_log.user_id).to be_nil
      expect(audit_log.auditable).to be_nil
      expect(audit_log.action).to eq('login_failed')
      expect(audit_log.object).to eq(
        'email' => 'unknown@example.com',
        'errors' => [ 'invalid credentials' ]
      )
    end
  end

  context 'when the password is incorrect' do
    let(:params) { { email: 'user@example.com', password: 'wrong-password' } }

    it 'returns an unauthorized error result' do
      expect(result.success?).to eq(false)
      expect(result.data).to eq(
        code: 'invalid_credentials',
        message: 'Invalid email or password',
        details: [ 'invalid credentials' ]
      )
    end

    it 'persists a login_failed audit log tied to the existing user' do
      expect { result }.to change(AuditLog, :count).by(1)

      audit_log = AuditLog.last
      expect(audit_log.user_id).to eq(user.id)
      expect(audit_log.auditable).to eq(user)
      expect(audit_log.action).to eq('login_failed')
    end
  end

  context 'when the user has exceeded the maximum number of failed login attempts' do
    let(:params) { { email: 'user@example.com', password: 'wrong-password' } }

    before do
      # Simulate multiple failed login attempts
      described_class::MAX_FAILED_ATTEMPTS.times do
        described_class.new(params: params).call
      end
    end

    it 'returns an account_locked error result' do
      expect(result.success?).to eq(false)
      expect(result.data).to eq(
        code: 'account_locked',
        message: 'Account is locked due to too many failed login attempts. Please try again later.',
        details: [ 'account locked' ]
      )
    end
  end
end
