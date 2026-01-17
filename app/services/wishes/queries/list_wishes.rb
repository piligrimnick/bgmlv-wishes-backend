module Wishes
  module Queries
    class ListWishes < ApplicationService
      option :filters, default: -> { {} }
      option :order, default: -> { 'created_at desc' }
      option :page, optional: true
      option :per_page, optional: true

      def call
        scope = Wish
          .includes(:user, :booking, :booker, picture_attachment: :blob)
          .where(filters)
          .order(order)

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

        count_scope = scope.unscope(:includes, :eager_load, :preload)
        total_count = count_scope.count

        wishes = scope.limit(per_page_num).offset((page_num - 1) * per_page_num).to_a

        Success(
          data: wishes,
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
