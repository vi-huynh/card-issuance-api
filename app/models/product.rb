class Product < ApplicationRecord
  include Auditable
  SORTABLE_FIELDS = %w[name created_at updated_at].freeze
  SORT_ORDER = %w[asc desc].freeze

  belongs_to :brand

  enum :status, { active: 0, inactive: 1 }
end
