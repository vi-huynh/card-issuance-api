class Client < ApplicationRecord
  include Auditable

  SORTABLE_FIELDS = %w[name created_at updated_at].freeze
  SORT_ORDER = %w[asc desc].freeze

  belongs_to :user

  has_many :cards, dependent: :destroy
  has_many :client_products, dependent: :destroy
  has_many :products, through: :client_products

  enum :status, { pending: 0, active: 1, inactive: 2 }

  validates :name, presence: true
  validates :payout_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
