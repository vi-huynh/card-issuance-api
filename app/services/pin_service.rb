class PinService
  def self.generate
    pin = SecureRandom.random_number(1_000_000).to_s.rjust(6, "0")
  end

  def self.pin_valid?(pin, pin_digest)
    BCrypt::Password.new(pin_digest) == pin
  end

  def self.hashed_pin(pin)
    BCrypt::Password.create(pin)
  end
end
