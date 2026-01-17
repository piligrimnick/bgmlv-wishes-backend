module Friendships
  module Queries
    class ListFriends < ApplicationService
      option :user_id
      option :page, optional: true
      option :per_page, optional: true

      def call
        # Get friend IDs from both directions
        friend_ids_as_requester = Friendship
          .where(requester_id: user_id, status: :accepted)
          .pluck(:addressee_id)

        friend_ids_as_addressee = Friendship
          .where(addressee_id: user_id, status: :accepted)
          .pluck(:requester_id)

        friend_ids = friend_ids_as_requester + friend_ids_as_addressee

        scope = User.where(id: friend_ids).order(created_at: :desc)

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
        total_count = scope.count
        users = scope.limit(per_page_num).offset((page_num - 1) * per_page_num).to_a

        Success(
          data: users,
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
