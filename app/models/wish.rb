class Wish < ApplicationRecord
  belongs_to :user
  belongs_to :wishlist

  has_one :booking, dependent: :destroy
  has_one :booker, through: :booking, source: :user

  has_one_attached :picture

  enum :state, { active: 0, realised: 1, cancelled: 2 }
end
