# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Clients::Products::IndexService do
  subject(:result) { described_class.new(client: client, params: params).call }

  let(:client) { create(:client, user: create(:user, role: :client)) }
  let(:brand_a) { create(:brand, name: 'Brand name 1') }
  let(:brand_b) { create(:brand, name: 'Brand name 2') }

  describe 'when the client has access to products across multiple brands' do
    let!(:product_a) { create(:product, brand: brand_a, name: 'Product name 1', price: 10, status: :active) }
    let!(:product_b) { create(:product, brand: brand_b, name: 'Product name 2', price: 20, status: :active) }
    let(:params) { {} }

    before do
      create(:client_product, client: client, product: product_a)
      create(:client_product, client: client, product: product_b)
    end

    it 'returns all accessible active products when searching with no filters' do
      expect(result.success?).to eq(true)
      expect(result.data[:items]).to match_array([ product_a, product_b ])
    end
  end

  describe 'when filtering by brand name' do
    let!(:product_a) { create(:product, brand: brand_a, name: 'Product name 1', price: 10, status: :active) }
    let!(:product_b) { create(:product, brand: brand_b, name: 'Product name 2', price: 20, status: :active) }
    let(:params) { { brand_name: 'name 1' } }

    before do
      create(:client_product, client: client, product: product_a)
      create(:client_product, client: client, product: product_b)
    end

    it 'returns only accessible active products from that brand' do
      expect(result.data[:items]).to eq([ product_a ])
    end
  end

  describe 'when filtering by price range' do
    let!(:product_low) { create(:product, brand: brand_a, name: 'Product name 3', price: 5, status: :active) }
    let!(:product_mid) { create(:product, brand: brand_a, name: 'Product name 4', price: 20, status: :active) }
    let!(:product_high) { create(:product, brand: brand_a, name: 'Product name 5', price: 50, status: :active) }
    let(:params) { { min_price: 15, max_price: 30 } }

    before do
      [ product_low, product_mid, product_high ].each { |product| create(:client_product, client: client, product: product) }
    end

    it 'returns only products within that range' do
      expect(result.data[:items]).to eq([ product_mid ])
    end
  end

  describe 'when filtering by product name' do
    let!(:matching) { create(:product, brand: brand_a, name: 'Product name 6', price: 10, status: :active) }
    let!(:non_matching) { create(:product, brand: brand_a, name: 'Product name 7', price: 10, status: :active) }
    let(:params) { { name: 'NAME 6' } }

    before do
      [ matching, non_matching ].each { |product| create(:client_product, client: client, product: product) }
    end

    it 'returns only products matching the name, case-insensitively' do
      expect(result.data[:items]).to eq([ matching ])
    end
  end

  describe 'when the client has no access to any active products' do
    let(:params) { {} }

    it 'returns an empty result set without error' do
      expect(result.success?).to eq(true)
      expect(result.data[:items]).to eq([])
    end
  end

  describe 'when a granted product is inactive' do
    let!(:inactive_product) { create(:product, brand: brand_a, name: 'Product name 8', price: 10, status: :inactive) }
    let(:params) { {} }

    before do
      create(:client_product, client: client, product: inactive_product)
    end

    it 'excludes it even though the access grant exists' do
      expect(result.data[:items]).to eq([])
      expect(ClientProduct.exists?(client_id: client.id, product_id: inactive_product.id)).to eq(true)
    end
  end

  describe 'when a granted product belongs to another client' do
    let(:other_client) { create(:client, user: create(:user, role: :client)) }
    let!(:product) { create(:product, brand: brand_a, name: 'Product name 9', price: 10, status: :active) }
    let(:params) { {} }

    before do
      create(:client_product, client: other_client, product: product)
    end

    it 'is not returned for a client without their own grant' do
      expect(result.data[:items]).to eq([])
    end
  end
end
