module Wishlists
  module Queries
    class FindWishlist < ApplicationService
      option :id

      def call
        wishlist = Wishlist.includes(:user).find_by(id: id)
        return Failure(:not_found) unless wishlist

        Success(wishlist)
      end
    end
  end
end

