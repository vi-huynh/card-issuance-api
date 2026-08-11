# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Admin::Products::CreateService do
  subject(:result) { service.call }

  let(:service) { described_class.new(params: params) }
  let(:admin) { create(:user) }
  let(:brand) { create(:brand) }

  before do
    Current.user = admin
  end

  describe 'when the params are valid' do
    let(:params) do
      {
        name: 'Product name 1',
        description: 'Product description',
        price: 9.99,
        brand_id: brand.id
      }
    end

    it 'persists a new product with the submitted attributes' do
      expect { result }.to change(Product, :count).by(1)

      product = Product.last
      expect(result.success?).to eq(true)
      expect(result.data).to eq(product)

      expect(product.name).to eq('Product name 1')
      expect(product.description).to eq('Product description')
      expect(product.price).to eq(9.99)
      expect(product.brand_id).to eq(brand.id)
      expect(product.brand).to eq(brand)
    end

    it 'records a create audit log tied to the admin and the new product' do
      brand

      expect { result }.to change(AuditLog, :count).by(1)

      audit_log = AuditLog.last
      expect(audit_log.user_id).to eq(admin.id)
      expect(audit_log.auditable).to eq(Product.last)
      expect(audit_log.auditable_type).to eq('Product')
      expect(audit_log).to be_action_create
      expected_object = params.stringify_keys.merge("price" => "9.99")
      expect(audit_log.object.slice(*params.keys.map(&:to_s))).to eq(expected_object)
      expect(audit_log.object_changes.slice(*params.keys.map(&:to_s)))
        .to eq(expected_object.transform_values { |v| [ nil, v ] })
    end
  end

  describe 'when the brand does not exist' do
    let(:params) { { name: 'Product name 2', price: 9.99, brand_id: 999 } }

    it 'does not persist a new product' do
      expect { result }.not_to change(Product, :count)
    end

    it 'does not record an audit log' do
      expect { result }.not_to change(AuditLog, :count)
    end

    it 'returns a failure result reporting the invalid brand' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('product_not_created')
      expect(result.data[:details][:brand]).to include('must exist')
    end
  end
end
