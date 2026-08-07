# frozen_string_literal: true

require "rails_helper"

RSpec.describe JwtService do
  include ActiveSupport::Testing::TimeHelpers

  describe '.encode' do
    subject { described_class.encode(payload) }

    let(:payload) do
      {
        user_id: 1,
        role: 0
      }
    end

    it 'returns an encrypted JWT token' do
      token = subject
      expect(token).to be_a(String)
      expect(token.length).to be > 0
    end
  end

  describe '.decode' do
    subject { described_class.decode(token) }

    let(:payload) do
      {
        user_id: 1,
        role: 0
      }
    end

    let(:token) { described_class.encode(payload) }

    it 'returns the original payload' do
      decoded_payload = subject
      expect(decoded_payload).to eq(payload.stringify_keys)
    end

    context 'when the token is invalid' do
      let(:token) { 'invalid.token.string' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when the token is expired' do
      let!(:token) { described_class.encode(payload) }

      it 'returns nil' do
        travel_to(JwtService::ACCESS_TOKEN_EXPIRATION_TIME.minutes.from_now + 1.second) do
          expect(subject).to be_nil
        end
      end
    end
  end
end
