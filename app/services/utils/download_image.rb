module Utils
  class DownloadImage < ApplicationService
    require 'open-uri'

    USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'.freeze

    option :url

    def call
      return nil if url.blank?

      begin
        # OpenURI follows redirects by default for same-scheme (HTTP->HTTP, HTTPS->HTTPS)
        # For cross-scheme redirects, additional configuration might be needed, but usually unnecessary for images.
        file = URI.open(url, 'User-Agent' => USER_AGENT, read_timeout: 10)
        
        return nil unless file.content_type.start_with?('image/')

        file
      rescue StandardError => e
        Rails.logger.error("Failed to download image from #{url}: #{e.message}")
        nil
      end
    end
  end
end
