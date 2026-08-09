# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

User.create!(email: "admin@example.com", password: "Admin@2026")

5.times do |i|
  brand = Brand.create!(
    name: "Brand #{i + 1}",
    description: "Description for Brand #{i + 1}",
    logo_url: "http://example.com/logo.png",
    contact_email: "contact-brand#{i + 1}@example.com"
  )
  5.times do |j|
    brand.products.create!(
      name: "Product #{j + 1}",
      description: "Description for Product #{j + 1}",
      price: (i + 1) * 10.0,
      currency: "USD"
    )
  end
end
