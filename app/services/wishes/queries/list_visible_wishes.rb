module Wishes
  module Queries
    class ListVisibleWishes < ApplicationService
      option :owner_id  # Whose wishes to fetch
      option :viewer_id, optional: true  # Who is viewing
      option :state, default: -> { :active }
      option :order, default: -> { 'created_at desc' }
      option :page, optional: true
      option :per_page, optional: true

      def call
        # Owner can see their own wishes
        if viewer_id == owner_id
          filters = { user_id: owner_id, state: state }
          return ::Wishes::Queries::ListWishes.call(
            filters: filters,
            order: order,
            page: page,
            per_page: per_page
          )
        end

        # Unauthenticated users cannot see any wishes
        return Success({ data: [], metadata: empty_metadata }) if viewer_id.nil?

        # Check friendship
        are_friends = Friendship.exists?(
          requester_id: [viewer_id, owner_id],
          addressee_id: [viewer_id, owner_id],
          status: :accepted
        )

        if are_friends
          filters = { user_id: owner_id, state: state }
          ::Wishes::Queries::ListWishes.call(
            filters: filters,
            order: order,
            page: page,
            per_page: per_page
          )
        else
          Success({ data: [], metadata: empty_metadata })
        end
      end

      private

      def empty_metadata
        {
          total_count: 0,
          page: (page || 1).to_i,
          per_page: (per_page || 20).to_i,
          total_pages: 0
        }
      end
    end
  end
end
