class DailyTaskJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info "Starting DailyTaskJob at #{Time.current}"
    
    result = Users::DeleteInactiveService.call
    
    Rails.logger.info "DailyTaskJob finished at #{Time.current}. Deleted #{result[:deleted_count]} users."
  end
end
