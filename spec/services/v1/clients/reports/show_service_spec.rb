# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Clients::Reports::ShowService do
  subject(:result) { described_class.new(client: client, params: params).call }

  let(:date_range) { { date_from: 1.year.ago.to_date, date_to: Date.tomorrow } }
  let(:brand) { create(:brand, name: "Brand name 1") }
  let(:product) { create(:product, brand: brand, name: "Product name 1") }
  let(:client) { create(:client, user: create(:user, email: "client-1@example.com", role: :client)) }
  let(:other_client) { create(:client, user: create(:user, email: "client-2@example.com", role: :client)) }

  let!(:issued_card) do
    create(:card, client: client, product: product, status: 0, amount: 10, current_balance: 4)
  end
  let!(:cancelled_card) do
    create(:card, client: client, product: product, status: 1, amount: 20, current_balance: 20)
  end
  let!(:other_client_card) do
    create(:card, client: other_client, product: product, status: 0, amount: 30, current_balance: 30)
  end

  describe 'when the client has activity in the selected date range' do
    let(:params) { date_range }

    it 'returns metrics scoped only to that client\'s cards' do
      expect(result.success?).to eq(true)
      expect(result.data).to eq(
        total_card: 2,
        total_card_issued: 1,
        total_card_cancelled: 1,
        total_issued_amount: 30.0.to_d,
        total_current_balance: 24.0.to_d,
        total_redeemed: 6.0.to_d
      )
    end

    it 'excludes other clients\' cards' do
      expect(result.data[:total_card]).not_to eq(3)
    end
  end

  describe 'when the client has no activity in the selected date range' do
    let(:params) { { date_from: 10.years.ago.to_date, date_to: 5.years.ago.to_date } }

    it 'returns zero values rather than an error' do
      expect(result.success?).to eq(true)
      expect(result.data).to eq(
        total_card: 0,
        total_card_issued: 0,
        total_card_cancelled: 0,
        total_issued_amount: 0.0.to_d,
        total_current_balance: 0.0.to_d,
        total_redeemed: 0.0.to_d
      )
    end
  end
end
