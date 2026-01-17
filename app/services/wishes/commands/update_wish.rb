module Wishes
  module Commands
    class UpdateWish < ApplicationService
      option :id
      option :body, optional: true
      option :url, optional: true

      def call
        wish = Wish.find(id)
        
        update_params = {}
        update_params[:body] = body if body
        update_params[:url] = url if url
        
        wish.update!(update_params)
        wish.reload

        Success(wish)
      rescue ActiveRecord::RecordNotFound => e
        Failure(:not_found)
      rescue ActiveRecord::RecordInvalid => e
        Failure(e.record.errors)
      end
    end
  end
end
