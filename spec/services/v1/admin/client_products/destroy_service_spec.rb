# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Admin::ClientProducts::DestroyService do
  subject(:result) { described_class.new(client_product: client_product).call }

  let(:admin) { create(:user, role: :admin) }
  let(:brand) { create(:brand) }
  let(:product) { create(:product, brand: brand, status: :active) }
  let(:client) { create(:client, user: create(:user, role: :client)) }
  let!(:client_product) { create(:client_product, client: client, product: product) }

  before do
    Current.user = admin
  end

  describe 'when the grant exists' do
    it 'revokes the client access to the product' do
      client_product

      expect { result }.to change(ClientProduct, :count).by(-1)
      expect(ClientProduct.exists?(client_id: client.id, product_id: product.id)).to eq(false)
    end

    it 'removes the product from the client accessible catalog' do
      client_product

      expect { result }.to change { client.reload.accessible_products.to_a }.from([ product ]).to([])
    end

    it 'returns a successful result with the destroyed grant' do
      destroyed = client_product

      expect(result.success?).to eq(true)
      expect(result.data).to eq(destroyed)
    end

    it 'records a delete audit log tied to the admin and the grant' do
      destroyed = client_product

      expect { result }.to change(AuditLog, :count).by(1)

      audit_log = AuditLog.last
      expect(audit_log.user_id).to eq(admin.id)
      expect(audit_log.auditable_id).to eq(destroyed.id)
      expect(audit_log.auditable_type).to eq('ClientProduct')
      expect(audit_log).to be_action_destroy
    end
  end
end
