# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Admin::Products::UpdateService do
  subject(:result) { service.call }

  let(:service) { described_class.new(product: product, params: params) }
  let(:admin) { create(:user) }
  let(:brand) { create(:brand) }
  let(:product) { create(:product, brand: brand, name: 'Original name', price: 5, description: 'Original description') }

  before do
    Current.user = admin
  end

  describe 'when the params are valid' do
    let(:params) do
      {
        name: 'Updated name',
        description: 'Updated description',
        price: 19.99,
        brand_id: brand.id
      }
    end

    it 'updates the product with the submitted attributes' do
      expect { result }.to change { product.reload.name }.from('Original name').to('Updated name')

      expect(result.success?).to eq(true)
      expect(result.data).to eq(product)
      expect(product.description).to eq('Updated description')
      expect(product.price).to eq(19.99)
      expect(product.brand_id).to eq(brand.id)
    end

    it 'records an update audit log tied to the admin and the product' do
      product

      expect { result }.to change(AuditLog, :count).by(1)

      audit_log = AuditLog.last
      expect(audit_log.user_id).to eq(admin.id)
      expect(audit_log.auditable).to eq(product)
      expect(audit_log.auditable_type).to eq('Product')
      expect(audit_log).to be_action_update
      expect(audit_log.object_changes['name']).to eq([ 'Original name', 'Updated name' ])
    end
  end

  describe 'when the new name is already taken by another product' do
    let!(:other_product) { create(:product, brand: brand, name: 'Taken name') }
    let(:params) { { name: 'Taken name', price: 5, brand_id: brand.id } }

    it 'does not change the product' do
      expect { result }.not_to change { product.reload.name }
    end

    it 'does not record an audit log' do
      product

      expect { result }.not_to change(AuditLog, :count)
    end

    it 'returns a failure result reporting the name is taken' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('product_not_updated')
      expect(result.data[:details]).to include('Product name already exists')
    end
  end

  describe 'when the same product keeps its own name' do
    let(:params) { { name: 'Original name', price: 25, brand_id: brand.id } }

    it 'updates the product without raising a false duplicate-name error' do
      expect(result.success?).to eq(true)
      expect(product.reload.price).to eq(25)
    end
  end

  describe 'when the status is changed' do
    let(:product) { create(:product, brand: brand, name: 'Original name', price: 5, status: 'inactive') }
    let(:params) { { name: 'Original name', price: 5, brand_id: brand.id, status: 'active' } }

    it 'updates the product status' do
      expect { result }.to change { product.reload.status }.from('inactive').to('active')

      expect(result.success?).to eq(true)
      expect(result.data.status).to eq('active')
    end

    it 'records an update audit log capturing the status change' do
      product

      expect { result }.to change(AuditLog, :count).by(1)

      audit_log = AuditLog.last
      expect(audit_log).to be_action_update
      expect(audit_log.object_changes['status']).to eq([ 'inactive', 'active' ])
    end
  end

  describe 'when the brand does not exist' do
    let(:params) { { name: 'Updated name', price: 19.99, brand_id: 0 } }

    it 'does not change the product' do
      expect { result }.not_to change { product.reload.brand_id }
    end

    it 'does not record an audit log' do
      product

      expect { result }.not_to change(AuditLog, :count)
    end

    it 'returns a failure result reporting the invalid brand' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('product_not_updated')
      expect(result.data[:details][:brand]).to include('must exist')
    end
  end
end
