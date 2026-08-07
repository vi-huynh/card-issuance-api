FactoryBot.define do
  factory :user do
    email { "MyString" }
    password_digest { "MyString" }
    role { 1 }
    invite_token_digest { "MyString" }
    invite_token_expires_at { "2026-08-07 15:11:45" }
    invited_at { "2026-08-07 15:11:45" }
    invite_accepted_at { "2026-08-07 15:11:45" }
  end
end
