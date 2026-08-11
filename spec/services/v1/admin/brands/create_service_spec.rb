# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Admin::Brands::CreateService do
  subject(:result) { service.call }

  let(:service) { described_class.new(params: params, current_user: admin) }
  let(:admin) { create(:user) }

  before do
    Current.user = admin
  end

  describe 'when the params is valid' do
    let(:params) do
      {
        name: 'Brand name 1',
        description: 'Brand description',
        logo_url: 'http://example.com/logo.png',
        contact_email: 'contact@example.com'
      }
    end

    it 'persists a new brand with the submitted attributes' do
      expect { result }.to change(Brand, :count).by(1)

      brand = Brand.last
      expect(result.data).to eq(brand)
      expect(brand.name).to eq('Brand name 1')
      expect(brand.description).to eq('Brand description')
      expect(brand.logo_url).to eq('http://example.com/logo.png')
      expect(brand.contact_email).to eq('contact@example.com')
    end

    it 'records a create audit log tied to the admin and the new brand' do
      expect { result }.to change(AuditLog, :count).by(1)

      audit_log = AuditLog.last
      expect(audit_log.user_id).to eq(admin.id)
      expect(audit_log.auditable).to eq(Brand.last)
      expect(audit_log).to be_action_create
      expect(audit_log.object.slice(*params.keys.map(&:to_s))).to eq(params.stringify_keys)
      expect(audit_log.object_changes.slice(*params.keys.map(&:to_s))).to eq(params.stringify_keys.transform_values { |v| [ nil, v ] })
    end
  end

  describe 'when the brand name is already taken' do
    let!(:existing_brand) { create(:brand, name: 'Brand name 2') }
    let(:params) { { name: 'Brand name 2' } }

    it 'does not persist a new brand' do
      expect { result }.not_to change(Brand, :count)
    end

    it 'does not record an audit log' do
      expect { result }.not_to change(AuditLog, :count)
    end

    it 'returns a failure result reporting the name is taken' do
      expect(result.success?).to eq(false)
      expect(result.data[:code]).to eq('brand_not_created')
      expect(result.data[:details][:name]).to include('has already been taken')
    end
  end
end
