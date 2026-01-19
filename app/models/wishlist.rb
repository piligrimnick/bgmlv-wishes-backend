class Wishlist < ApplicationRecord
  belongs_to :user
  has_many :wishes, dependent: :destroy

  enum :visibility, { public: 0, private: 1 }, default: :private, prefix: true

  validates :name, presence: true
  validates :is_default, uniqueness: { scope: :user_id }, if: :is_default?
end
