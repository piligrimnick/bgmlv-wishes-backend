module Friendships
  module Commands
    class SendFriendRequest < ApplicationService
      option :requester_id
      option :addressee_id

      def call
        # Validations
        return Failure(:cannot_friend_yourself) if requester_id == addressee_id
        return Failure(:requester_not_found) unless User.exists?(requester_id)
        return Failure(:addressee_not_found) unless User.exists?(addressee_id)

        # Check for existing friendship in either direction
        existing = Friendship.find_by(
          requester_id: [requester_id, addressee_id],
          addressee_id: [requester_id, addressee_id]
        )

        if existing
          case existing.status
          when 'accepted'
            return Failure(:already_friends)
          when 'pending'
            # If reverse pending exists, auto-accept (both users wanted to be friends)
            if existing.requester_id == addressee_id
              existing.update!(status: :accepted)
              return Success(existing)
            else
              return Failure(:request_already_sent)
            end
          when 'rejected'
            # Allow re-requesting after rejection (reset to pending)
            existing.update!(status: :pending, updated_at: Time.current)
            return Success(existing)
          end
        end

        # Create new friendship request
        friendship = Friendship.create!(
          requester_id: requester_id,
          addressee_id: addressee_id,
          status: :pending
        )

        Success(friendship)
      rescue ActiveRecord::RecordInvalid => e
        Failure(e.record.errors)
      end
    end
  end
end
