# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Clients::Cards::CancelService do
  subject(:result) { described_class.new(card: card).call }

  let(:client_user) { create(:user, role: :client) }
  let(:client) { create(:client, user: client_user) }
  let(:brand) { create(:brand) }
  let(:product) { create(:product, brand: brand, price: 25, status: :active) }

  before do
    Current.user = client_user
  end

  describe 'when the card is issued' do
    let!(:card) { create(:card, client: client, product: product, status: :issued) }

    it 'changes the card status to cancelled' do
      expect { result }.to change { card.reload.status }.from('issued').to('cancelled')
    end

    it 'returns a successful result with the cancelled card' do
      expect(result.success?).to eq(true)
      expect(result.data).to eq(card)
    end

    it 'records an update audit log capturing the status transition and the actor' do
      expect { result }.to change(AuditLog, :count).by(1)

      audit_log = AuditLog.last
      expect(audit_log.user_id).to eq(client_user.id)
      expect(audit_log.auditable).to eq(card)
      expect(audit_log.auditable_type).to eq('Card')
      expect(audit_log).to be_action_update
      expect(audit_log.object_changes['status']).to eq([ 'issued', 'cancelled' ])
    end
  end

  describe 'when the card is already cancelled' do
    let!(:card) { create(:card, client: client, product: product, status: :cancelled) }

    it 'does not change the card' do
      expect { result }.not_to change { card.reload.updated_at }
    end

    it 'does not record an audit log' do
      expect { result }.not_to change(AuditLog, :count)
    end

    it 'returns a failure result reporting it is already cancelled' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('card_already_cancelled')
    end
  end
end
