class Card < ApplicationRecord
  include Auditable

  belongs_to :client
  belongs_to :product

  enum :status, { issued: 0, cancelled: 1 }
  attr_accessor :pin

  validates :activation_number, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :current_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
