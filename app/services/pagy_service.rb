# frozen_string_literal: true

require "pagy/extras/countless"

class PagyService
  include Singleton
  include Pagy::Backend

  def paginate_with_pagy(object, params)
    if (params["countless"] || params[:countless]).present?
      paginate_with_pagy_countless(object, params)
    else
      paginate_with_pagy_count(object, params)
    end
  end

  def paginate_with_pagy_count(object, params)
    page = params["page"] || params[:page] || 1
    items = params["limit"] || params[:limit] || 10

    pagy, records = pagy(
      object,
      page:,
      items:
    )

    pagination = {
      page: pagy.page,
      items: pagy.items,
      total_pages: pagy.pages,
      total_items: pagy.count
    }
    [ records, pagination ]
  end

  def paginate_with_pagy_countless(object, params)
    page = params["page"] || params[:page] || 1
    items = params["limit"] || params[:limit] || 10

    pagy, records = pagy_countless(
      object,
      page:,
      items:
    )

    pagination = {
      page: pagy.page,
      items: pagy.items,
      next: pagy.next
    }
    [ records, pagination ]
  end
end
