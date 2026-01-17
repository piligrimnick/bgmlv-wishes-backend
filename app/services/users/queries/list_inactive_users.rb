module Users
  module Queries
    class ListInactiveUsers < ApplicationService
      def call
        users = User
                .where.missing(:wishes, :bookings)
                .to_a

        Success(users)
      end
    end
  end
end
