FactoryBot.define do
  factory :audit_log do
    user { nil }
    action { "MyString" }
    auditable { nil }
    ip_address { "" }
    created_at { "2026-08-07 15:12:38" }
  end
end
