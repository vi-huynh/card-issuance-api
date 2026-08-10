FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "correct-password" }
    role { 1 }
    invite_token { nil }
    invite_token_expires_at { nil }
    invited_at { nil }
    invite_accepted_at { nil }
  end
end
