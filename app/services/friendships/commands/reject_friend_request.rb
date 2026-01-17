module Friendships
  module Commands
    class RejectFriendRequest < ApplicationService
      option :friendship_id
      option :addressee_id

      def call
        friendship = Friendship.find_by(id: friendship_id)
        return Failure(:not_found) unless friendship

        # Authorization
        return Failure(:forbidden) unless friendship.addressee_id == addressee_id
        return Failure(:not_pending) unless friendship.pending?

        friendship.update!(status: :rejected)
        friendship.reload

        Success(friendship)
      rescue ActiveRecord::RecordInvalid => e
        Failure(e.record.errors)
      end
    end
  end
end
