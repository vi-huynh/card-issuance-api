# frozen_string_literal: true

class ApplicationService
  Result = Struct.new(:success?, :data, keyword_init: true)

  def initialize(params: {})
    @params = params
  end

  def call
    raise NotImplementedError,
          "Subclasses must implement #call and return an ApplicationService::Result"
  end

  private

  def success(data: {})
    Result.new(success?: true, data: data)
  end

  def error(code:, message:, details: nil)
    Result.new(success?: false, data: { code:, message:, details: })
  end
end
