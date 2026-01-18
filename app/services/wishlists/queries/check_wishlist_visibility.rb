module Wishlists
  module Queries
    # Authorization/policy helper:
    # can_view_wishlist?(viewer, wishlist)
    #
    # Rules:
    # - owner: yes
    # - public: yes
    # - private: only accepted friends
    class CheckWishlistVisibility < ApplicationService
      option :wishlist
      option :viewer_id, optional: true # nil = unauthenticated

      def call
        wishlist_owner_id = wishlist.user_id
        normalized_viewer_id = viewer_id&.to_i

        # Owner can always see
        return Success(true) if normalized_viewer_id == wishlist_owner_id

        # Public wishlists are visible to anyone (incl. unauthenticated)
        return Success(true) if wishlist.visibility_public?

        # Private wishlists require authentication + accepted friendship
        return Success(false) if normalized_viewer_id.nil?

        friends = Friendship.exists?(
          requester_id: [normalized_viewer_id, wishlist_owner_id],
          addressee_id: [normalized_viewer_id, wishlist_owner_id],
          status: :accepted
        )

        Success(friends)
      end
    end
  end
end

