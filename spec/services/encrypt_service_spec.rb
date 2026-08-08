# frozen_string_literal: true

require "rails_helper"

RSpec.describe EncryptService do
  include ActiveSupport::Testing::TimeHelpers

  describe '.encrypt' do
    subject { described_class.encrypt(payload) }

    let(:payload) { "sensitive-data" }

    it 'returns an encrypted token' do
      token = subject
      expect(token).to be_a(String)
      expect(token).not_to eq(payload)
    end
  end

  describe '.decrypt' do
    subject { described_class.decrypt(token) }

    let(:payload) { "sensitive-data" }
    let(:token) { described_class.encrypt(payload) }

    it 'returns the original payload' do
      expect(subject).to eq(payload)
    end

    context 'when the token was encrypted with a different purpose' do
      let(:token) { described_class.encrypt(payload, purpose: :other_purpose) }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when the token is invalid' do
      let(:token) { 'invalid.token.string' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when the token is blank' do
      let(:token) { '' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when the token is expired' do
      let!(:token) { described_class.encrypt(payload, expires_in: 1.minute) }

      it 'returns nil' do
        travel_to(2.minutes.from_now) do
          expect(subject).to be_nil
        end
      end
    end
  end
end
