FactoryBot.define do
  factory :client do
    user { nil }
    name { "MyString" }
    payout_rate { "9.99" }
    status { 1 }
  end
end
