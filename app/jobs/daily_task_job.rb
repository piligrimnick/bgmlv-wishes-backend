class DailyTaskJob < ApplicationJob
  queue_as :default

  def perform(*args)
    result = Users::DeleteInactiveService.call
    if result.success?
      Rails.logger.info("Deleted #{result.value!} users.")
    else
      Rails.logger.error(result.failure)
    end
  end
end
