module Friendships
  module Commands
    class RemoveFriendship < ApplicationService
      option :friendship_id
      option :user_id  # Either requester or addressee

      def call
        friendship = Friendship.find_by(id: friendship_id)
        return Failure(:not_found) unless friendship

        # Authorization: either party can remove friendship
        is_participant = [friendship.requester_id, friendship.addressee_id].include?(user_id)
        return Failure(:forbidden) unless is_participant

        # Can only remove accepted friendships
        return Failure(:not_accepted) unless friendship.accepted?

        friendship.destroy!
        Success(true)
      rescue ActiveRecord::RecordNotFound
        Failure(:not_found)
      end
    end
  end
end
