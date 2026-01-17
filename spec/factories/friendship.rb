FactoryBot.define do
  factory :friendship do
    association :requester, factory: :user
    association :addressee, factory: :user
    status { :pending }

    trait :pending do
      status { :pending }
    end

    trait :accepted do
      status { :accepted }
    end

    trait :rejected do
      status { :rejected }
    end
  end
end
