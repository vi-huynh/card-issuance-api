# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

User.find_or_create_by!(email: "admin@example.com") do |user|
  user.password = "Admin@2026"
end

brands = 5.times.map do |i|
  brand = Brand.find_or_create_by!(name: "Brand #{i + 1}") do |b|
    b.description = "Description for Brand #{i + 1}"
    b.logo_url = "http://example.com/logo.png"
    b.contact_email = "contact-brand#{i + 1}@example.com"
  end

  5.times do |j|
    brand.products.find_or_create_by!(name: "Product #{j + 1}") do |product|
      product.price = (i + 1) * 10.0
      product.status = 0
    end
  end

  brand
end

# Clients, granted product access, and issued cards spread across brands/clients/dates
# so the admin/client report endpoints have meaningful data to aggregate.
5.times do |i|
  user = User.find_or_create_by!(email: "client#{i + 1}@example.com") do |u|
    u.password = "Client@2026"
    u.role = :client
  end

  client = Client.find_or_create_by!(user: user) do |c|
    c.name = "Client #{i + 1}"
    c.payout_rate = 10 + i
    c.status = :active
  end

  next if client.cards.exists?

  # Each client gets access to products from two brands, so brand-scoped
  # and client-scoped reports both have overlapping and non-overlapping data.
  accessible_brands = [ brands[i % brands.size], brands[(i + 1) % brands.size] ]
  products = Product.where(brand_id: accessible_brands.map(&:id))

  products.each do |product|
    ClientProduct.find_or_create_by!(client: client, product: product)
  end

  20.times do |k|
    product = products.sample
    cancelled = k.even? && k % 6 == 0
    current_balance = cancelled ? product.price : (product.price * rand(0..80) / 100.0).round(2)
    created_at = rand(365).days.ago - rand(24).hours

    card = Card.new(
      client: client,
      product: product,
      activation_number: SecureRandom.hex(8).upcase,
      pin_digest: PinService.hashed_pin("1234"),
      status: cancelled ? :cancelled : :issued,
      amount: product.price,
      current_balance: current_balance,
      currency: "USD",
      purchase_details: {}
    )
    card.save!
    card.update_column(:created_at, created_at)
  end
end
