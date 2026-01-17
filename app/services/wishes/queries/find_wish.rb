module Wishes
  module Queries
    class FindWish < ApplicationService
      option :id
      option :filters, default: -> { {} }

      def call
        wish = Wish
               .includes(:user, :booking, :booker, picture_attachment: :blob)
               .find_by(filters.merge(id: id))

        wish ? Success(wish) : Failure(:not_found)
      end
    end
  end
end
