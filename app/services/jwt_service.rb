# frozen_string_literal: true

require "singleton"

class JwtService
  include Singleton

  SECRET_KEY = ENV.fetch("JWT_SECRET_KEY", "sample-key")
  ACCESS_TOKEN_EXPIRATION_TIME = ENV.fetch("ACCESS_TOKEN_ACCESS_TOKEN_EXPIRATION_TIME", 30).to_i
  ENCRYPTION_PURPOSE = :jwt

  def initialize
    @encrypt_service = EncryptService.instance
  end

  def encode(data)
    jwt = JWT.encode({ data:, exp: ACCESS_TOKEN_EXPIRATION_TIME.minutes.from_now.to_i }, SECRET_KEY, "HS256")
    @encrypt_service.encrypt(jwt, purpose: ENCRYPTION_PURPOSE)
  end

  def decode(token)
    jwt = EncryptService.decrypt(token, purpose: ENCRYPTION_PURPOSE)
    return nil if jwt.nil?

    payload = JWT.decode jwt, SECRET_KEY, true, { algorithm: "HS256", verify_expiration: true }
    payload.first["data"]
  rescue => e
    Rails.logger.error("Error decoding JWT: #{e.message}")
    nil
  end

  class << self
    def encode(...)
      instance.encode(...)
    end

    def decode(...)
      instance.decode(...)
    end
  end
end
