FactoryBot.define do
  factory :wishlist do
    user
    name { "Default" }
    description { nil }
    visibility { :private }
  end
end
