module Wishes
  module Commands
    class UpdateWish < ApplicationService
      option :id
      option :body, optional: true
      option :url, optional: true
      option :wishlist_id, optional: true

      def call
        wish = Wish.find(id)

        update_params = {}
        update_params[:body] = body if body
        update_params[:url] = url if url

        if wishlist_id
          # Validate that the wishlist belongs to the user
          wishlist = Wishlist.find_by(id: wishlist_id, user_id: wish.user_id)
          return Failure("Wishlist not found or not owned by user") unless wishlist
          update_params[:wishlist_id] = wishlist_id
        end

        wish.update!(update_params)
        wish.reload

        Success(wish)
      rescue ActiveRecord::RecordNotFound
        Failure(:not_found)
      rescue ActiveRecord::RecordInvalid => e
        Failure(e.record.errors)
      end
    end
  end
end
