module Users
  module Queries
    class FindUser < ApplicationService
      option :id

      def call
        user = User.find_by(id: id)
        user ? Success(user) : Failure(:not_found)
      end
    end
  end
end
