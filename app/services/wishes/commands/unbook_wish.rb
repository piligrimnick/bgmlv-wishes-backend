module Wishes
  module Commands
    class UnbookWish < ApplicationService
      option :wish_id
      option :booker_id

      def call
        wish = Wish.find(wish_id)
        
        if wish.booking&.user_id == booker_id
          wish.booking.destroy!
        end
        
        wish.reload
        Success(wish)
      rescue ActiveRecord::RecordNotFound => e
        Failure(:not_found)
      end
    end
  end
end
