FactoryBot.define do
  factory :product do
    brand { nil }
    name { "MyString" }
    price { "9.99" }
    status { 1 }
  end
end
