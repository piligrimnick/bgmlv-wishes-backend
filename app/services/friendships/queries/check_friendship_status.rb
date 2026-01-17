module Friendships
  module Queries
    class CheckFriendshipStatus < ApplicationService
      option :user_id
      option :other_user_id

      def call
        # Check both directions
        friendship = Friendship.find_by(
          requester_id: [user_id, other_user_id],
          addressee_id: [user_id, other_user_id]
        )

        if friendship.nil?
          Success({ status: :none, friendship: nil })
        elsif friendship.requester_id == user_id
          Success({ status: "outgoing_#{friendship.status}", friendship: friendship })
        else
          Success({ status: "incoming_#{friendship.status}", friendship: friendship })
        end
      end
    end
  end
end
