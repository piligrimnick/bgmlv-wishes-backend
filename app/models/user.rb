class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :wishes

  has_many :bookings, dependent: :destroy
  has_many :booked_wishes, through: :bookings, source: :wish

  # Friendship associations
  has_many :initiated_friendships,
           class_name: 'Friendship',
           foreign_key: :requester_id,
           dependent: :destroy

  has_many :received_friendships,
           class_name: 'Friendship',
           foreign_key: :addressee_id,
           dependent: :destroy

  # Friends (mutual, accepted friendships)
  has_many :friends_as_requester,
           -> { where(friendships: { status: :accepted }) },
           through: :initiated_friendships,
           source: :addressee

  has_many :friends_as_addressee,
           -> { where(friendships: { status: :accepted }) },
           through: :received_friendships,
           source: :requester

  # Convenience method to get all friends
  def friends
    User.where(id: friends_as_requester.pluck(:id) + friends_as_addressee.pluck(:id))
  end
end
