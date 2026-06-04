class EventRefreshJob < ApplicationJob
  queue_as :default

  def perform
    result = Events::Ingestor.run(mode: :refresh, fetch_images: true)
    Rails.logger.info "[EventRefreshJob] #{result[:upserted]} events upserted in #{result[:elapsed]}s"
  end
end
