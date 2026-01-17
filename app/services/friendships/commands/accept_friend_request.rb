module Friendships
  module Commands
    class AcceptFriendRequest < ApplicationService
      option :friendship_id
      option :addressee_id  # User accepting the request (authorization)

      def call
        friendship = Friendship.find_by(id: friendship_id)
        return Failure(:not_found) unless friendship

        # Authorization: only the addressee can accept
        return Failure(:forbidden) unless friendship.addressee_id == addressee_id

        # Can only accept pending requests
        return Failure(:not_pending) unless friendship.pending?

        friendship.update!(status: :accepted)
        friendship.reload

        Success(friendship)
      rescue ActiveRecord::RecordInvalid => e
        Failure(e.record.errors)
      end
    end
  end
end
