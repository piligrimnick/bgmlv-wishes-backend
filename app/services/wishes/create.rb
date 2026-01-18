module Wishes
  class Create < ApplicationService
    option :user_id
    option :wish do
      option :body
      option :url, optional: true
      option :picture, optional: true
      option :wishlist_id, optional: true
    end

    def call
      Wishes::Commands::CreateWish.call(
        user_id: user_id,
        **wish.to_h.symbolize_keys
      )
    end
  end
end
