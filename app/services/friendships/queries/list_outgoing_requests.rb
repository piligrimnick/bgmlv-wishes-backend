module Friendships
  module Queries
    class ListOutgoingRequests < ApplicationService
      option :user_id
      option :page, optional: true
      option :per_page, optional: true

      def call
        scope = Friendship
          .includes(:addressee)
          .where(requester_id: user_id, status: :pending)
          .order(created_at: :desc)

        if page || per_page
          paginate(scope)
        else
          Success(scope.to_a)
        end
      end

      private

      def paginate(scope)
        page_num = (page || 1).to_i
        per_page_num = (per_page || 20).to_i
        total_count = scope.count(:all)
        friendships = scope.limit(per_page_num).offset((page_num - 1) * per_page_num).to_a

        Success(
          data: friendships,
          metadata: {
            total_count: total_count,
            page: page_num,
            per_page: per_page_num,
            total_pages: (total_count.to_f / per_page_num).ceil
          }
        )
      end
    end
  end
end
