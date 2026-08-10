# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Admin::Products::IndexService do
  subject(:result) { described_class.new(params: params).call }

  let(:brand) { create(:brand) }

  describe 'listing products' do
    let!(:products) { create_list(:product, 3, brand: brand) }
    let(:params) { {} }

    it 'returns every persisted product' do
      expect(result.success?).to eq(true)
      expect(result.data[:items]).to match_array(products)
    end

    it 'returns pagination metadata reflecting the total count' do
      pagination = result.data[:pagination]

      expect(pagination[:page]).to eq(1)
      expect(pagination[:total_items]).to eq(3)
    end
  end

  describe 'filtering by brand_id' do
    let!(:other_brand) { create(:brand) }
    let!(:matching_products) { create_list(:product, 2, brand: brand) }
    let!(:other_products) { create_list(:product, 2, brand: other_brand) }
    let(:params) { { brand_id: brand.id } }

    it 'returns only products belonging to that brand' do
      expect(result.data[:items]).to match_array(matching_products)
    end
  end

  describe 'pagination' do
    let!(:products) { create_list(:product, 15, brand: brand) }

    context 'on the first page with a custom per_page' do
      let(:params) { { page: 1, per_page: 5 } }

      it 'returns only that page worth of items' do
        expect(result.data[:items].size).to eq(5)
      end

      it 'reports the correct pagination metadata' do
        pagination = result.data[:pagination]

        expect(pagination[:page]).to eq(1)
        expect(pagination[:items]).to eq(5)
        expect(pagination[:total_items]).to eq(15)
        expect(pagination[:total_pages]).to eq(3)
      end
    end

    context 'on the second page' do
      let(:params) { { page: 2, per_page: 5 } }

      it 'returns the next slice of items, not overlapping the first page' do
        first_page_ids = described_class.new(params: { page: 1, per_page: 5 }).call.data[:items].map(&:id)
        second_page_ids = result.data[:items].map(&:id)

        expect(second_page_ids.size).to eq(5)
        expect(second_page_ids & first_page_ids).to be_empty
      end
    end
  end

  describe 'sorting' do
    let!(:product_b) { create(:product, brand: brand, name: 'Bravo') }
    let!(:product_a) { create(:product, brand: brand, name: 'Alpha') }
    let!(:product_c) { create(:product, brand: brand, name: 'Charlie') }

    context 'sorted by name ascending' do
      let(:params) { { sort_by: 'name', sort_order: 'asc' } }

      it 'returns products ordered alphabetically' do
        expect(result.data[:items]).to eq([ product_a, product_b, product_c ])
      end
    end

    context 'sorted by name descending' do
      let(:params) { { sort_by: 'name', sort_order: 'desc' } }

      it 'returns products in reverse alphabetical order' do
        expect(result.data[:items]).to eq([ product_c, product_b, product_a ])
      end
    end
  end

  describe 'when there are no products' do
    let(:params) { {} }

    it 'returns an empty list without error' do
      expect(result.success?).to eq(true)
      expect(result.data[:items]).to eq([])
      expect(result.data[:pagination][:total_items]).to eq(0)
    end
  end
end
