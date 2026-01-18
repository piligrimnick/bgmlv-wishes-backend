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

        resolved_wishlist_id = wishlist_id || Wishlist.where(user_id: user_id).order(:id).pick(:id)

        if resolved_wishlist_id.nil?
          resolved_wishlist_id = Wishlist.create!(
            user_id: user_id,
            name: 'Default',
            visibility: :private
          ).id
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
