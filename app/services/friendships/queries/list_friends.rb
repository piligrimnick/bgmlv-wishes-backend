module Friendships
  module Queries
    class ListFriends < ApplicationService
      option :user_id
      option :page, optional: true
      option :per_page, optional: true

      def call
        # Get friendships from both directions with friend data
        friendships_as_requester = Friendship
          .includes(:addressee)
          .where(requester_id: user_id, status: :accepted)

        friendships_as_addressee = Friendship
          .includes(:requester)
          .where(addressee_id: user_id, status: :accepted)

        # Build array of friends with friendship_id
        friends = []

        friendships_as_requester.each do |friendship|
          friend = friendship.addressee
          friend.define_singleton_method(:friendship_id) { friendship.id }
          friends << friend
        end

        friendships_as_addressee.each do |friendship|
          friend = friendship.requester
          friend.define_singleton_method(:friendship_id) { friendship.id }
          friends << friend
        end

        # Sort by created_at desc
        friends.sort_by! { |f| -f.created_at.to_i }

        if page || per_page
          paginate_array(friends)
        else
          Success(friends)
        end
      end

      private

      def paginate_array(array)
        page_num = (page || 1).to_i
        per_page_num = (per_page || 20).to_i
        total_count = array.size
        offset = (page_num - 1) * per_page_num
        users = array[offset, per_page_num] || []

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
