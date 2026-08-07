require 'singleton'

class EncryptService
  include Singleton

  SECRET = ENV.fetch('ENCRYPTOR_SECRET', '')
  SALT   = ENV.fetch('ENCRYPTOR_SALT', '')

  def initialize
    # 1. Derive a 32-byte key using KeyGenerator
    key_len = ActiveSupport::MessageEncryptor.key_len
    key_generator = ActiveSupport::KeyGenerator.new(SECRET)
    key = key_generator.generate_key(SALT, key_len)

    # 2. Initialize ActiveSupport::MessageEncryptor (uses AES-256-GCM by default)
    @crypt = ActiveSupport::MessageEncryptor.new(key)
  end
  
  def encrypt(payload, purpose: :egift_pin, expires_in: nil)
    @crypt.encrypt_and_sign(payload, purpose: purpose, expires_in: expires_in)
  end

  def decrypt(encrypted_data, purpose: :egift_pin)
    return nil if encrypted_data.blank?

    @crypt.decrypt_and_verify(encrypted_data, purpose: purpose)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature => e
    nil
  end

  class << self
    def encrypt(...)
      instance.encrypt(...)
    end

    def decrypt(...)
      instance.decrypt(...)
    end
  end
end