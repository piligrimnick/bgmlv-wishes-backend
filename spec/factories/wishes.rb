FactoryBot.define do
  factory :wish do
    body { Faker::Lorem.sentence }
    url { Faker::Internet.url }
    state { :active }
    user

    wishlist do
      user.default_wishlist || create(:wishlist, :default, user: user)
    end
  end
end
