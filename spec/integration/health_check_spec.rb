# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Health Check', type: :request do
  describe 'GET /health_check' do
    it 'returns a successful ok status' do
      get '/health_check', as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ 'data' => { 'status' => 'ok' } })
    end
  end
end
