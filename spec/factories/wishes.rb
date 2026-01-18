FactoryBot.define do
  factory :wish do
    body { Faker::Lorem.sentence }
    url { Faker::Internet.url }
    state { :active }
    user

    wishlist { association :wishlist, user: user }
  end
end
