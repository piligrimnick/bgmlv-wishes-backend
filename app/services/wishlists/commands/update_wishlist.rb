module Wishlists
  module Commands
    class UpdateWishlist < ApplicationService
      option :id
      option :user_id
      option :name, optional: true
      option :description, optional: true
      option :visibility, optional: true

      def call
        wishlist_result = ::Wishlists::Queries::FindWishlist.call(id: id)
        return Failure(:not_found) if wishlist_result.failure?

        wishlist = wishlist_result.value!

        # Check ownership
        return Failure(:forbidden) if wishlist.user_id != user_id.to_i

        updates = {}
        updates[:name] = name if name.present?
        updates[:description] = description if description.present?
        updates[:visibility] = visibility if visibility.present?

        if wishlist.update(updates)
          Success(wishlist.reload)
        else
          Failure(wishlist.errors)
        end
      end
    end
  end
end
