class Client < ApplicationRecord
  belongs_to :user

  has_many :cards, dependent: :destroy
  has_many :client_products, dependent: :destroy
  has_many :products, through: :client_products
  
  enum status: { inactive:  0, active: 1 }
end
