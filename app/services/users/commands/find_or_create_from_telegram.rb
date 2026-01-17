module Users
  module Commands
    class FindOrCreateFromTelegram < ApplicationService
      option :chat_id
      option :username, optional: true
      option :firstname, optional: true
      option :lastname, optional: true

      def call
        user = User
               .create_with(
                 username: username,
                 firstname: firstname,
                 lastname: lastname
               )
               .find_or_create_by!(telegram_id: chat_id)

        Success(user)
      rescue ActiveRecord::RecordInvalid => e
        Failure(e.record.errors)
      end
    end
  end
end
