module Users
  class DeleteInactiveService < ApplicationService
    def call
      inactive_users = RepositoryRegistry.for(:users).inactive
      
      count = inactive_users.count
      Rails.logger.info "Found #{count} inactive users for deletion"
      
      if count > 0
        ids = inactive_users.map(&:id)
        User.where(id: ids).destroy_all
      end
      
      { deleted_count: count }
    end
  end
end
