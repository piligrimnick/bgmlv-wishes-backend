module Wishes
  module Queries
    class CheckWishVisibility < ApplicationService
      option :wish
      option :viewer_id, optional: true  # nil = unauthenticated

      def call
        # Owner can always see their wishes
        return Success(true) if viewer_id == wish.user_id

        # Not logged in = no access (privacy-by-default)
        return Success(false) if viewer_id.nil?

        # Check if viewer is friends with wish owner
        friendship_exists = Friendship.exists?(
          requester_id: [viewer_id, wish.user_id],
          addressee_id: [viewer_id, wish.user_id],
          status: :accepted
        )

        Success(friendship_exists)
      end
    end
  end
end
