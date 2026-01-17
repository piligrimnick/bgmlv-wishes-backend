module Wishes
  class Realise < ApplicationService
    option :wish_id

    def call
      result = Wishes::Commands::RealiseWish.call(wish_id: wish_id)
      # update_statistic
      # send_email
      result
    end
  end
end
