module Wishes
  module Commands
    class CreateWish < ApplicationService
      option :user_id
      option :body, optional: true
      option :url, optional: true
      option :picture, optional: true
      option :wishlist_id, optional: true

      def call
        wish = nil

        if wishlist_id
          # Validate that the wishlist belongs to the user
          wishlist = Wishlist.find_by(id: wishlist_id, user_id: user_id)
          return Failure("Wishlist not found or not owned by user") unless wishlist
          resolved_wishlist_id = wishlist_id
        else
          # Find or create default wishlist
          default_wishlist = Wishlist.find_by(user_id: user_id, is_default: true)
          unless default_wishlist
            default_wishlist = Wishlist.create!(
              user_id: user_id,
              name: 'Default',
              visibility: :private,
              is_default: true
            )
          end
          resolved_wishlist_id = default_wishlist.id
        end

        Wish.transaction do
          wish = Wish.create!(
            user_id: user_id,
            wishlist_id: resolved_wishlist_id,
            body: body,
            url: url
          )

          if picture.present?
            filename = picture.respond_to?(:original_filename) ? picture.original_filename : 'image'
            wish.picture.attach(io: picture, filename: "#{wish.id}_#{filename}")
            wish.save
          end
        end

        wish.reload
        Success(wish)
      rescue ActiveRecord::RecordInvalid => e
        Failure(e.record.errors)
      end
    end
  end
end
