class Brand < ApplicationRecord
  include Auditable
  SORTABLE_FIELDS = %w[name created_at updated_at].freeze
  SORT_ORDER = %w[asc desc].freeze

  has_many :products, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
