# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Admin::Products::DestroyService do
  subject(:result) { service.call }

  let(:service) { described_class.new(product: product) }
  let(:admin) { create(:user) }
  let(:brand) { create(:brand) }
  let(:product) { create(:product, brand: brand) }

  before do
    Current.user = admin
  end

  describe 'when the product has no issued cards' do
    it 'destroys the product' do
      product

      expect { result }.to change(Product, :count).by(-1)
      expect(Product.exists?(product.id)).to eq(false)
    end

    it 'returns a successful result with the destroyed product' do
      destroyed_product = product

      expect(result.success?).to eq(true)
      expect(result.data).to eq(destroyed_product)
    end

    it 'records a delete audit log tied to the admin and the product' do
      destroyed_product = product

      expect { result }.to change(AuditLog, :count).by(1)

      audit_log = AuditLog.last
      expect(audit_log.user_id).to eq(admin.id)
      expect(audit_log.auditable_id).to eq(destroyed_product.id)
      expect(audit_log.auditable_type).to eq('Product')
      expect(audit_log.action_destroy?).to eq(true)
    end
  end

  describe 'when the product has one or more issued cards' do
    let(:client_user) { create(:user) }
    let(:client) { Client.create!(user: client_user, name: 'Client name', payout_rate: 1, status: :active) }

    before do
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

    it 'does not destroy the product' do
      product

      expect { result }.not_to change(Product, :count)
    end

    it 'does not record an audit log' do
      product

      expect { result }.not_to change(AuditLog, :count)
    end

    it 'returns a failure result reporting the product is in use' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('product_not_destroyed')
      expect(result.data[:details]).to include('Product is in use')
    end
  end

  describe 'when the product does not exist' do
    let(:product) { nil }

    it 'does not record an audit log' do
      expect { result }.not_to change(AuditLog, :count)
    end

    it 'returns a failure result reporting the product was not found' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('product_not_destroyed')
      expect(result.data[:details]).to include('Product not found')
    end
  end
end
