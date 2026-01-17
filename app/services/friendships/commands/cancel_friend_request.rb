module Friendships
  module Commands
    class CancelFriendRequest < ApplicationService
      option :friendship_id
      option :requester_id

      def call
        friendship = Friendship.find_by(id: friendship_id)
        return Failure(:not_found) unless friendship

        # Authorization: only requester can cancel
        return Failure(:forbidden) unless friendship.requester_id == requester_id

        # Can only cancel pending requests
        return Failure(:not_pending) unless friendship.pending?

        friendship.destroy!
        Success(true)
      rescue ActiveRecord::RecordNotFound
        Failure(:not_found)
      end
    end
  end
end
