FactoryBot.define do
  factory :card do
    client { nil }
    product { nil }
    sequence(:activation_number) { |n| "ACTIVATION#{n}" }
    pin { "123467" }
    status { 0 }
    amount { "9.99" }
    current_balance { "9.99" }
    currency { "USD" }
    purchase_details { {} }
  end
end
