module Wishes
  class Realise < ApplicationService
    option :wish_id

    def call
      Wishes::Commands::RealiseWish.call(wish_id: wish_id)
      # update_statistic
      # send_email
    end
  end
end
