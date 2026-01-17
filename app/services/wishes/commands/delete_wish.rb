module Wishes
  module Commands
    class DeleteWish < ApplicationService
      option :id
      option :filters, default: -> { {} }

      def call
        wish = Wish.find_by(filters.merge(id: id))

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
