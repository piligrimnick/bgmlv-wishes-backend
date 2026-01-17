module Users
  class DeleteInactiveService < ApplicationService
    def call
      result = Users::Queries::ListInactiveUsers.call

      return Failure(:query_failed) if result.failure?

      inactive_users = result.value!
      user_ids = inactive_users.map(&:id)

      User.where(id: user_ids).destroy_all

      Success(user_ids.count)
    end
  end
end
