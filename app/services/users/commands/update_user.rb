module Users
  module Commands
    class UpdateUser < ApplicationService
      option :id
      option :email, optional: true
      option :password, optional: true
      option :username, optional: true
      option :firstname, optional: true
      option :lastname, optional: true

      def call
        user = User.find(id)

        update_params = {}
        update_params[:email] = email if email
        update_params[:password] = password if password
        update_params[:username] = username if username
        update_params[:firstname] = firstname if firstname
        update_params[:lastname] = lastname if lastname

        user.update!(update_params)
        user.reload

        Success(user)
      rescue ActiveRecord::RecordNotFound
        Failure(:not_found)
      rescue ActiveRecord::RecordInvalid => e
        Failure(e.record.errors)
      end
    end
  end
end
