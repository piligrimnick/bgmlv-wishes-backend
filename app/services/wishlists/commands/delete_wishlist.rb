module Wishlists
  module Commands
    class DeleteWishlist < ApplicationService
      option :id
      option :user_id
      option :confirm, default: -> { false }

      def call
        # Check confirm flag
        return Failure({ confirm: ["confirmation_required"] }) unless confirm

        wishlist_result = ::Wishlists::Queries::FindWishlist.call(id: id)
        return Failure(:not_found) if wishlist_result.failure?

        wishlist = wishlist_result.value!

        # Check ownership
        return Failure(:forbidden) if wishlist.user_id != user_id.to_i

        # The delete will cascade via has_many :wishes, dependent: :destroy
        wishlist.destroy
        Success(true)
      end
    end
  end
end
