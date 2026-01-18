module Wishlists
  module Queries
    class ListUserWishlists < ApplicationService
      option :user_id
      option :viewer_id, optional: true

      def call
        owner_id = user_id.to_i
        normalized_viewer_id = viewer_id&.to_i

        scope = Wishlist.where(user_id: owner_id).order('created_at asc')

        # Owner can see all
        if normalized_viewer_id == owner_id
          return Success(scope.to_a)
        end

        # Unauthenticated viewers see only public
        if normalized_viewer_id.nil?
          return Success(scope.where(visibility: :public).to_a)
        end

        # Friends see all, others see only public
        friends = Friendship.exists?(
          requester_id: [normalized_viewer_id, owner_id],
          addressee_id: [normalized_viewer_id, owner_id],
          status: :accepted
        )

        if friends
          Success(scope.to_a)
        else
          Success(scope.where(visibility: :public).to_a)
        end
      end
    end
  end
end

