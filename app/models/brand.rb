class Brand < ApplicationRecord
  include Auditable

  has_many :products, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  SORTABLE_FIELDS = %w[name created_at updated_at].freeze
  SORT_ORDER = %w[asc desc].freeze
end
