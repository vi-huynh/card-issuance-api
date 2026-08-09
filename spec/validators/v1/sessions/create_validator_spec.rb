# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Sessions::CreateValidator do
  subject(:result) { described_class.new.call(params) }

  context 'with a valid email and password' do
    let(:params) { { email: 'user@example.com', password: 'correct-password' } }

    it 'succeeds' do
      expect(result.success?).to eq(true)
    end

    it 'returns the validated attributes' do
      expect(result.to_h).to eq(email: 'user@example.com', password: 'correct-password')
    end
  end

  context 'when email is missing' do
    let(:params) { { password: 'correct-password' } }

    it 'fails' do
      expect(result.success?).to eq(false)
    end

    it 'reports the email as missing' do
      expect(result.errors.to_h[:email]).to include('is missing')
    end
  end

  context 'when email is malformed' do
    let(:params) { { email: 'not-an-email', password: 'correct-password' } }

    it 'fails' do
      expect(result.success?).to eq(false)
    end

    it 'reports the email as invalid format' do
      expect(result.errors.to_h[:email]).to include('is in invalid format')
    end
  end

  context 'when email exceeds the max size' do
    let(:params) { { email: "#{'a' * 250}@example.com", password: 'correct-password' } }

    it 'fails' do
      expect(result.success?).to eq(false)
    end

    it 'reports the email as too long' do
      expect(result.errors.to_h[:email]).to include('size cannot be greater than 255')
    end
  end

  context 'when password is missing' do
    let(:params) { { email: 'user@example.com' } }

    it 'fails' do
      expect(result.success?).to eq(false)
    end

    it 'reports the password as missing' do
      expect(result.errors.to_h[:password]).to include('is missing')
    end
  end

  context 'when password is blank' do
    let(:params) { { email: 'user@example.com', password: '' } }

    it 'fails' do
      expect(result.success?).to eq(false)
    end

    it 'reports the password as not filled' do
      expect(result.errors.to_h[:password]).to include('must be filled')
    end
  end
end
