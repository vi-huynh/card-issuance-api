# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Admin::Brands::IndexValidator do
  subject(:result) { described_class.new.call(params) }
  context 'with parameters is empty' do
    let(:params) { {} }
    it 'succeeds' do
      expect(result.success?).to eq(true)
    end
  end

  context 'with valid page and per_page values' do
    let(:params) { { page: 1, per_page: 10 } }

    it 'succeeds' do
      expect(result.success?).to eq(true)
    end

    it 'returns the validated attributes' do
      expect(result.to_h).to eq(page: 1, per_page: 10)
    end
  end

  context 'with all fields provided' do
    let(:params) do
      {
        page: 1,
        per_page: 10,
        sort_by: 'name',
        sort_order: 'asc'
      }
    end

    it 'succeeds' do
      expect(result.success?).to eq(true)
    end

    it 'returns the validated attributes' do
      expect(result.to_h).to eq(params)
    end
  end

  context 'when sort_by is invalid' do
    let(:params) { { page: 1, per_page: 10, sort_by: 'invalid_field', sort_order: 'asc' } }

    it 'fails' do
      expect(result.success?).to eq(false)
    end

    it 'returns the error message' do
      expect(result.errors.to_h).to have_key(:sort_by)
    end
  end

  context 'when sort_order is invalid' do
    let(:params) { { page: 1, per_page: 10, sort_by: 'name', sort_order: 'invalid_order' } }

    it 'fails' do
      expect(result.success?).to eq(false)
    end

    it 'returns the error message' do
      expect(result.errors.to_h).to have_key(:sort_order)
    end
  end
end
