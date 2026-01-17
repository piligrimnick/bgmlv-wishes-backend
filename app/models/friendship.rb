class Friendship < ApplicationRecord
  belongs_to :requester, class_name: 'User'
  belongs_to :addressee, class_name: 'User'

  enum :status, { pending: 0, accepted: 1, rejected: 2 }

  validates :requester_id, presence: true
  validates :addressee_id, presence: true
  validates :requester_id, uniqueness: { scope: :addressee_id }

  # Prevent self-friendship
  validate :users_cannot_be_friends_with_themselves

  # Prevent duplicate friendship in reverse direction
  validate :friendship_uniqueness_bidirectional, on: :create

  scope :accepted_friendships, -> { where(status: :accepted) }
  scope :pending_requests, -> { where(status: :pending) }

  private

  def users_cannot_be_friends_with_themselves
    errors.add(:addressee_id, "can't be the same as requester") if requester_id == addressee_id
  end

  def friendship_uniqueness_bidirectional
    # Check if reverse direction already exists
    exists = Friendship.exists?(
      requester_id: addressee_id,
      addressee_id: requester_id
    )
    errors.add(:base, "Friendship already exists in reverse direction") if exists
  end
end
