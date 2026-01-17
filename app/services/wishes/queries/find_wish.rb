module Wishes
  module Queries
    class FindWish < ApplicationService
      option :id
      option :filters, default: -> { {} }

      def call
        wish = Wish
          .includes(:user, :booking, :booker, picture_attachment: :blob)
          .where(filters.merge(id: id))
          .take

        wish ? Success(wish) : Failure(:not_found)
      end
    end
  end
end
