module Users
  class FindOrCreateFromTelegram < ApplicationService
    option :chat_id
    option :username, optional: true
    option :firstname, optional: true
    option :lastname, optional: true

    def call
      Users::Commands::FindOrCreateFromTelegram.call(
        chat_id: chat_id,
        username: username,
        firstname: firstname,
        lastname: lastname
      )
    end
  end
end
