module Users
  module Commands
    class CreateUser < ApplicationService
      option :email, optional: true
      option :password, optional: true
      option :username, optional: true
      option :firstname, optional: true
      option :lastname, optional: true
      option :telegram_id, optional: true

      def call
        user = User.create!(
          email: email,
          password: password,
          username: username,
          firstname: firstname,
          lastname: lastname,
          telegram_id: telegram_id
        )

        Success(user)
      rescue ActiveRecord::RecordInvalid => e
        Failure(e.record.errors)
      end
    end
  end
end
