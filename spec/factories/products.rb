FactoryBot.define do
  factory :product do
    brand { nil }
    sequence(:name) { |n| "Product name #{n}" }
    price { "9.99" }
    status { 0 }
  end
end
