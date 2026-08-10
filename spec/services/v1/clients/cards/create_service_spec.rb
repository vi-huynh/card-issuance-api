# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Clients::Cards::CreateService do
  subject(:result) { service.call }

  let(:service) { described_class.new(client: client, params: params) }
  let(:client_user) { create(:user, role: :client) }
  let(:brand) { create(:brand) }
  let(:product) { create(:product, brand: brand, price: 25, status: :active) }
  let(:client) { create(:client, user: client_user) }

  before do
    Current.user = client_user
  end

  describe 'when the client has access to an active product' do
    let(:params) { { product_id: product.id, pin: '1234', purchase_details: { channel: 'web' } } }

    before do
      create(:client_product, client: client, product: product)
    end

    it 'issues a card with a unique activation number and issued status' do
      expect { result }.to change(Card, :count).by(1)

      card = Card.last
      expect(card.client).to eq(client)
      expect(card.product).to eq(product)
      expect(card.activation_number).to be_present
      expect(card.amount).to eq(product.price)
      expect(card.current_balance).to eq(product.price)
      expect(card.purchase_details).to eq('channel' => 'web')
      expect(card.status).to eq('issued')
    end

    it 'returns a successful result with the persisted card' do
      expect(result.success?).to eq(true)
      expect(result.data).to eq(Card.last)
    end

    it 'generates a unique activation number even if one is already taken' do
      taken_number = 'AAAAAAAAAAAAAAAA'
      allow(SecureRandom).to receive(:hex).and_return('aaaaaaaaaaaaaaaa', 'bbbbbbbbbbbbbbbb')
      create(:card, client: client, product: product, activation_number: taken_number)

      card = result.data
      expect(card.activation_number).to eq('BBBBBBBBBBBBBBBB')
    end

    it 'records a create audit log referencing the client and product via the card' do
      result
      audit_log = AuditLog.last
      expect(audit_log.user_id).to eq(client_user.id)
      expect(audit_log.auditable).to eq(Card.last)
      expect(audit_log.auditable_type).to eq('Card')
      expect(audit_log).to be_action_create
      expect(audit_log.object['client_id']).to eq(client.id)
      expect(audit_log.object['product_id']).to eq(product.id)
    end
  end

  describe 'when the product does not exist' do
    let(:params) { { product_id: 0 } }

    it 'does not issue a card' do
      client

      expect { result }.not_to change(Card, :count)
    end

    it 'returns a failure result reporting the product was not found' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('product_not_found')
    end
  end

  describe 'when the client does not have access to the product' do
    let(:params) { { product_id: product.id } }

    it 'does not issue a card' do
      product
      client

      expect { result }.not_to change(Card, :count)
    end

    it 'returns a failure result reporting access is forbidden' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('forbidden')
    end
  end

  describe 'when the product is inactive' do
    let(:product) { create(:product, brand: brand, price: 10, status: :inactive) }
    let(:params) { { product_id: product.id } }

    before do
      create(:client_product, client: client, product: product)
    end

    it 'does not issue a card' do
      expect { result }.not_to change(Card, :count)
    end

    it 'does not record an audit log' do
      expect { result }.not_to change(AuditLog, :count)
    end

    it 'returns a failure result reporting the product is not available' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('product_not_available')
    end
  end
end
