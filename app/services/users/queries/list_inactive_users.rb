module Users
  module Queries
    class ListInactiveUsers < ApplicationService
      def call
        users = User
          .left_outer_joins(:wishes, :bookings)
          .where(wishes: { id: nil }, bookings: { id: nil })
          .to_a

        Success(users)
      end
    end
  end
end
