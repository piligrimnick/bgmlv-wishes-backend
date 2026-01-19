module Wishlists
  module Commands
    class CreateWishlist < ApplicationService
      option :user_id
      option :name
      option :description, optional: true
      option :visibility, default: -> { :private }

      def call
        wishlist = Wishlist.create!(
          user_id: user_id,
          name: name,
          description: description,
          visibility: visibility,
          is_default: false # New wishlists are not default by default
        )

        Success(wishlist)
      rescue ActiveRecord::RecordInvalid => e
        Failure(e.record.errors)
      end
    end
  end
end
