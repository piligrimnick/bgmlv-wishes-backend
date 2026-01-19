FactoryBot.define do
  factory :wishlist do
    user
    name { "Default" }
    description { nil }
    visibility { :private }
    is_default { false }

    trait :default do
      name { "Default" }
      is_default { true }
    end
  end
end
