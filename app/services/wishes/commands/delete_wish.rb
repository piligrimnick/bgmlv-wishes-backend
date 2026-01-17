module Wishes
  module Commands
    class DeleteWish < ApplicationService
      option :id
      option :filters, default: -> { {} }

      def call
        wish = Wish.where(filters.merge(id: id)).take
        
        if wish
          wish.destroy!
          Success(true)
        else
          Failure(:not_found)
        end
      rescue ActiveRecord::RecordNotDestroyed => e
        Failure(e.record.errors)
      end
    end
  end
end
