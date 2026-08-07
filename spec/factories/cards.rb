FactoryBot.define do
  factory :card do
    client { nil }
    product { nil }
    activation_number { "MyString" }
    pin { "MyString" }
    status { 1 }
    amount { "9.99" }
    current_balance { "9.99" }
    currency { "MyString" }
    purchase_details { "" }
  end
end
