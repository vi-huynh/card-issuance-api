# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Admin::Brands::CreateValidator do
  subject(:result) { described_class.new.call(params) }

  context 'with a valid name only' do
    let(:params) { { name: 'Brand name 1' } }

    it 'succeeds' do
      expect(result.success?).to eq(true)
    end

    it 'returns the validated attributes' do
      expect(result.to_h).to eq(name: 'Brand name 1')
    end
  end

  context 'with all fields provided' do
    let(:params) do
      {
        name: 'Brand name 1',
        description: 'Brand description',
        logo_url: 'http://example.com/logo.png',
        contact_email: 'contact@example.com'
      }
    end

    it 'succeeds' do
      expect(result.success?).to eq(true)
    end

    it 'returns the validated attributes' do
      expect(result.to_h).to eq(params)
    end
  end

  context 'when name is missing' do
    let(:params) { {} }

    it 'fails' do
      expect(result.success?).to eq(false)
    end

    it 'reports the name as missing' do
      expect(result.errors.to_h[:name]).to include('is missing')
    end
  end

  context 'when name is blank' do
    let(:params) { { name: '' } }

    it 'fails' do
      expect(result.success?).to eq(false)
    end

    it 'reports the name as not filled' do
      expect(result.errors.to_h[:name]).to include('must be filled')
    end
  end

  context 'when name exceeds the max size' do
    let(:params) { { name: 'a' * 256 } }

    it 'fails' do
      expect(result.success?).to eq(false)
    end

    it 'reports the name as too long' do
      expect(result.errors.to_h[:name]).to include('size cannot be greater than 255')
    end
  end

  context 'when contact_email is malformed' do
    let(:params) { { name: 'Brand name 2', contact_email: 'not-an-email' } }

    it 'fails' do
      expect(result.success?).to eq(false)
    end

    it 'reports the contact_email as invalid format' do
      expect(result.errors.to_h[:contact_email]).to include('is in invalid format')
    end
  end

  context 'when optional fields are explicitly nil' do
    let(:params) { { name: 'Brand name 2', description: nil, logo_url: nil, contact_email: nil } }

    it 'succeeds' do
      expect(result.success?).to eq(true)
    end
  end
end
