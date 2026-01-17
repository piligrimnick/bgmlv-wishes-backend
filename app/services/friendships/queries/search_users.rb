module Friendships
  module Queries
    class SearchUsers < ApplicationService
      option :query
      option :current_user_id
      option :page, optional: true
      option :per_page, optional: true

      def call
        # Use PostgreSQL ILIKE for simple search (MVP approach)
        scope = User
          .where.not(id: current_user_id)  # Exclude current user
          .where(
            'username ILIKE :q OR firstname ILIKE :q OR lastname ILIKE :q',
            q: "%#{sanitize_query}%"
          )
          .order(username: :asc)
          .limit(50)  # Hard limit to prevent abuse

        if page || per_page
          paginate(scope)
        else
          Success(scope.to_a)
        end
      end

      private

      def sanitize_query
        # Basic SQL injection protection (ActiveRecord also handles this)
        query.to_s.strip.gsub(/[%_]/, '')
      end

      def paginate(scope)
        page_num = (page || 1).to_i
        per_page_num = [(per_page || 20).to_i, 50].min  # Max 50 per page
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
