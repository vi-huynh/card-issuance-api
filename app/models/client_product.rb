class ClientProduct < ApplicationRecord
  include Auditable

  belongs_to :client
  belongs_to :product

  validates :product_id, uniqueness: { scope: :client_id, message: "already granted to this client" }
end
