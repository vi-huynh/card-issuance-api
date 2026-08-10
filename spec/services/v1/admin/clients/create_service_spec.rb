# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Admin::Clients::CreateService do
  subject(:result) { service.call }

  let(:service) { described_class.new(params: params) }
  let(:admin) { create(:user, role: :admin) }

  before do
    Current.user = admin
  end

  describe 'when the params are valid' do
    let(:params) { { name: 'Name Client', email: 'client-email@example.com', payout_rate: 15.5 } }

    it 'persists a new user backing the client, with the client role and an invite token' do
      expect { result }.to change(User, :count).by(1).and change(Client, :count).by(1)

      user = User.last
      expect(user.email).to eq('client-email@example.com')
      expect(user.role).to eq('client')
      expect(user.invite_token).to be_present
      expect(user.invite_token_expires_at).to be_within(1.minute).of(24.hours.from_now)
      expect(user.invited_at).to be_within(1.minute).of(Time.current)
      expect(user.invite_accepted_at).to be_nil
    end

    it 'persists a new client linked to the user, with the submitted attributes' do
      expect { result }.to change(Client, :count).by(1)

      client = Client.last
      expect(client.user).to eq(User.last)
      expect(client.name).to eq('Name Client')
      expect(client.payout_rate).to eq(15.5)
      expect(client.status).to eq('pending')
    end

    it 'returns a successful result with the persisted client and the raw invite token' do
      expect(result.success?).to eq(true)
      expect(result.data[:client]).to eq(Client.last)
      expect(result.data[:invite_token]).to eq(Client.last.user.invite_token)
    end

    it 'records a create audit log tied to the admin and the new client' do
      expect { result }.to change(AuditLog, :count).by(1)

      audit_log = AuditLog.last
      expect(audit_log.user_id).to eq(admin.id)
      expect(audit_log.auditable).to eq(Client.last)
      expect(audit_log.auditable_type).to eq('Client')
      expect(audit_log).to be_action_create
      expect(audit_log.object.slice('name', 'payout_rate')).to eq('name' => 'Name Client', 'payout_rate' => '15.5')
      expect(audit_log.object_changes.slice('name', 'payout_rate'))
        .to eq('name' => [ nil, 'Name Client' ], 'payout_rate' => [ nil, '15.5' ])
    end
  end

  describe 'when the email is already taken' do
    let!(:existing_user) { create(:user, email: 'client-email@example.com') }
    let(:params) { { name: 'Name Client', email: 'client-email@example.com', payout_rate: 15.5 } }

    it 'does not persist a new user' do
      expect { result }.not_to change(User, :count)
    end

    it 'does not persist a new client' do
      expect { result }.not_to change(Client, :count)
    end

    it 'does not record an audit log' do
      expect { result }.not_to change(AuditLog, :count)
    end

    it 'returns a failure result reporting the email is taken' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('client_not_created')
      expect(result.data[:details][:email]).to include('has already been taken')
    end
  end

  describe 'when the payout rate is negative' do
    let(:params) { { name: 'Name Client', email: 'client-email@example.com', payout_rate: -5 } }

    it 'does not persist a new user (the transaction rolls back)' do
      expect { result }.not_to change(User, :count)
    end

    it 'does not persist a new client' do
      expect { result }.not_to change(Client, :count)
    end

    it 'does not record an audit log' do
      expect { result }.not_to change(AuditLog, :count)
    end

    it 'returns a failure result reporting the invalid payout rate' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('client_not_created')
      expect(result.data[:details][:payout_rate]).to include('must be greater than or equal to 0')
    end
  end

  describe 'when the payout rate is over 100' do
    let(:params) { { name: 'Name Client', email: 'client-email@example.com', payout_rate: 150 } }

    it 'does not persist a new user (the transaction rolls back)' do
      expect { result }.not_to change(User, :count)
    end

    it 'returns a failure result reporting the invalid payout rate' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('client_not_created')
      expect(result.data[:details][:payout_rate]).to include('must be less than or equal to 100')
    end
  end

  describe 'when the name is missing' do
    let(:params) { { name: '', email: 'client-email@example.com', payout_rate: 15.5 } }

    it 'does not persist a new user (the transaction rolls back)' do
      expect { result }.not_to change(User, :count)
    end

    it 'returns a failure result reporting the missing name' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('client_not_created')
      expect(result.data[:details][:name]).to include("can't be blank")
    end
  end
end
