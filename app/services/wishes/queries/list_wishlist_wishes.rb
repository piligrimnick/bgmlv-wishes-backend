module Wishes
  module Queries
    class ListWishlistWishes < ApplicationService
      option :wishlist_id

      def call
        wishes = Wish
          .includes(:user, :booking, :booker, :wishlist, picture_attachment: :blob)
          .where(wishlist_id: wishlist_id)
          .order('created_at desc')

        Success(wishes.to_a)
      end
    end
  end
end

