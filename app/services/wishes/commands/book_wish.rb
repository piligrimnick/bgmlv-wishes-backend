module Wishes
  module Commands
    class BookWish < ApplicationService
      option :wish_id
      option :booker_id

      def call
        wish = Wish.find(wish_id)
        booker = User.find(booker_id)

        wish.update!(booker: booker)
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
