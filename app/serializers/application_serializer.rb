class ApplicationSerializer < ActiveModel::Serializer
  def updated_at
    I18n.l(object.updated_at)
  end

  def created_at
    I18n.l(object.created_at)
  end
end
