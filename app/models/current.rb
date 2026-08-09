# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user, :ip_address
end
