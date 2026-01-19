module Wishes
  module Policies
    class BookingPolicy
      def self.can_book_wishlist_wish?(viewer, wishlist_owner)
        return false if viewer.nil?
        return false if viewer.id == wishlist_owner.id

        accepted_friendship_exists?(
          user_a: viewer,
          user_b: wishlist_owner
        )
      end

      private

      def self.accepted_friendship_exists?(user_a:, user_b:)
        Friendship.where(
          status: :accepted
        ).where(
          "(requester_id = :a AND addressee_id = :b) OR (requester_id = :b AND addressee_id = :a)",
          a: user_a.id,
          b: user_b.id
        ).exists?
      end
    end
  end
end
