# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Clients::Cards', type: :request do
  let(:client_user) { create(:user, role: :client) }
  let(:client) { create(:client, user: client_user) }
  let(:client_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: client_user.id)}" } }
  let(:admin) { create(:user, role: :admin) }
  let(:admin_headers) { { 'Authorization' => "Bearer #{JwtService.encode(user_id: admin.id)}" } }
  let(:brand) { create(:brand) }

  describe 'POST /v1/clients/cards' do
    context 'when the client has access to an active product' do
      let!(:product) { create(:product, brand: brand, price: 25, status: :active) }

      before do
        create(:client_product, client: client, product: product)
      end

      it 'issues a card and returns activation number, pin, and purchase details' do
        post '/v1/clients/cards', headers: client_headers, params: { product_id: product.id }, as: :json

        expect(response).to have_http_status(:created)
        data = JSON.parse(response.body)['data']
        expect(data['activation_number']).to be_present
        expect(data['pin']).to be_present
        expect(data['status']).to eq('issued')
        expect(data['purchase_details']).to eq({})
      end

      it 'returns a 403 forbidden status for a non-client (e.g. an admin)' do
        post '/v1/clients/cards', headers: admin_headers, params: { product_id: product.id }, as: :json

        expect(response).to have_http_status(:forbidden)
      end

      it 'returns a 400 bad request status when product_id is missing' do
        post '/v1/clients/cards', headers: client_headers, params: {}, as: :json

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the client does not have access to the product' do
      let!(:product) { create(:product, brand: brand, price: 25, status: :active) }

      it 'returns a 403 forbidden status' do
        client

        post '/v1/clients/cards', headers: client_headers, params: { product_id: product.id }, as: :json

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the product is inactive' do
      let!(:product) { create(:product, brand: brand, price: 25, status: :inactive) }

      before do
        create(:client_product, client: client, product: product)
      end

      it 'returns a 422 unprocessable entity status reporting the product is not available' do
        post '/v1/clients/cards', headers: client_headers, params: { product_id: product.id }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)['error']['code']).to eq('product_not_available')
      end
    end

    context 'when the product does not exist' do
      it 'returns a 404 not found status' do
        client

        post '/v1/clients/cards', headers: client_headers, params: { product_id: 999_999 }, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH /v1/clients/cards/:id/cancel' do
    let!(:product) { create(:product, brand: brand, price: 25, status: :active) }

    context 'when the client owns the card and it is issued' do
      let!(:card) { create(:card, client: client, product: product, status: :issued) }

      it 'cancels the card' do
        patch "/v1/clients/cards/#{card.id}/cancel", headers: client_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['status']).to eq('cancelled')
        expect(card.reload.status).to eq('cancelled')
      end
    end

    context 'when the client owns the card and it is already cancelled' do
      let!(:card) { create(:card, client: client, product: product, status: :cancelled) }

      it 'returns a 422 unprocessable entity status without changing the card' do
        patch "/v1/clients/cards/#{card.id}/cancel", headers: client_headers, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)['error']['code']).to eq('card_already_cancelled')
      end
    end

    context 'when the card belongs to another client' do
      let(:other_client) { create(:client, user: create(:user, role: :client)) }
      let!(:card) { create(:card, client: other_client, product: product, status: :issued) }

      it 'returns a 404 not found status' do
        client

        patch "/v1/clients/cards/#{card.id}/cancel", headers: client_headers, as: :json

        expect(response).to have_http_status(:not_found)
        expect(card.reload.status).to eq('issued')
      end
    end

    context 'when the card does not exist' do
      it 'returns a 404 not found status' do
        client

        patch '/v1/clients/cards/999999/cancel', headers: client_headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user is not a client (e.g. an admin)' do
      let!(:card) { create(:card, client: client, product: product, status: :issued) }

      it 'returns a 403 forbidden status' do
        patch "/v1/clients/cards/#{card.id}/cancel", headers: admin_headers, as: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
