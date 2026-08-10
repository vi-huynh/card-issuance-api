class User < ApplicationRecord
  has_secure_password

  has_one :client, dependent: :destroy

  enum :role, { admin: 0, client: 1 }

  validates :email, presence: true, uniqueness: true
end
