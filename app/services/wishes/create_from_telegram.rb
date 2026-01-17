module Wishes
  class CreateFromTelegram < ApplicationService
    option :user
    option :message_text

    def call
      Wishes::Create.call(user_id: user[:id], wish: Wishes::PrepareFromText.call(message_text))
    end
  end
end
