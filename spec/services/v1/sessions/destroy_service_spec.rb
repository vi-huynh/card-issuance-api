# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Sessions::DestroyService do
  subject(:result) { service.call }
  let!(:current_user) { create(:user, email: 'user@example.com', password: 'correct-password') }


  let(:service) do
    described_class.new(
      current_user:
    )
  end

  it 'records a log_out audit log tied to the current user' do
    expect { result }.to change(AuditLog, :count).by(1)

    audit_log = AuditLog.last
    expect(audit_log.user_id).to eq(current_user.id)
    expect(audit_log.auditable).to eq(current_user)
    expect(audit_log.action).to eq('log_out')
  end

  it 'returns a successful result with a confirmation message' do
    expect(result.success?).to eq(true)
    expect(result.data).to eq(message: 'Successfully logged out')
  end
end
