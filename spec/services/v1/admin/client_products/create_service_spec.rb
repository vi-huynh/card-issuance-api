# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Admin::ClientProducts::CreateService do
  subject(:result) { service.call }

  let(:service) { described_class.new(client: client, params: params) }
  let(:admin) { create(:user, role: :admin) }
  let(:brand) { create(:brand) }
  let!(:product) { create(:product, brand: brand, status: :active) }
  let!(:client) { create(:client, user: create(:user, role: :client)) }

  before do
    Current.user = admin
  end

  describe 'when the params are valid' do
    let(:params) { { product_id: product.id } }

    it 'grants the client access to the product' do
      expect { result }.to change(ClientProduct, :count).by(1)
      client_product = ClientProduct.last
      expect(result.success?).to eq(true)
      expect(result.data).to eq(client_product)
      expect(client_product.client).to eq(client)
      expect(client_product.product).to eq(product)
    end

    it 'records a create audit log tied to the admin and the new grant' do
      expect { result }.to change(AuditLog, :count).by(1)

      audit_log = AuditLog.last
      expect(audit_log.user_id).to eq(admin.id)
      expect(audit_log.auditable).to eq(ClientProduct.last)
      expect(audit_log.auditable_type).to eq('ClientProduct')
      expect(audit_log).to be_action_create
    end
  end

  describe 'when the client already has access to the product' do
    let!(:existing_grant) { create(:client_product, client: client, product: product) }
    let(:params) { { product_id: product.id } }

    it 'does not create a duplicate grant' do
      expect { result }.not_to change(ClientProduct, :count)
    end

    it 'does not record an audit log' do
      expect { result }.not_to change(AuditLog, :count)
    end

    it 'returns a failure result reporting the duplicate grant' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('client_product_not_created')
      expect(result.data[:details][:product_id]).to include('already granted to this client')
    end
  end

  describe 'when the product does not exist' do
    let(:params) { { product_id: 0 } }

    it 'does not create a grant' do
      expect { result }.not_to change(ClientProduct, :count)
    end

    it 'does not record an audit log' do
      expect { result }.not_to change(AuditLog, :count)
    end

    it 'returns a failure result reporting the invalid product' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('client_product_not_created')
      expect(result.data[:details][:product]).to include('must exist')
    end
  end
end
