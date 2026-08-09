FactoryBot.define do
  factory :brand do
    sequence(:name) { |n| "Brand #{n}" }
    description { "Brand description" }
    logo_url { "https://example.com/logo.png" }
    contact_email { "brand@example.com" }
  end
end
