module Wishes
  module Commands
    class RealiseWish < ApplicationService
      option :wish_id

      def call
        wish = Wish.find(wish_id)
        wish.realised!
        wish.reload

        Success(wish)
      rescue ActiveRecord::RecordNotFound
        Failure(:not_found)
      end
    end
  end
end
