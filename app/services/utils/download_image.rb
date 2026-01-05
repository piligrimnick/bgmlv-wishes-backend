module Utils
  class DownloadImage < ApplicationService
    require "down"

    USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36".freeze

    option :url

    def call
      return nil if url.blank?

      begin
        # Down handles redirects, timeouts, and creates unique temporary files.
        # It's more robust and thread-safe than OpenURI for concurrent downloads.
        tempfile = Down.download(
          url,
          headers: { "User-Agent" => USER_AGENT },
          open_timeout: 5,
          read_timeout: 10,
          max_redirects: 5
        )

        # Strictly check that it's an image
        unless tempfile.content_type.start_with?("image/")
          tempfile.close!
          return nil
        end

        tempfile
      rescue Down::Error => e
        Rails.logger.error("Failed to download image from #{url}: #{e.message}")
        nil
      rescue StandardError => e
        Rails.logger.error("Unexpected error downloading image from #{url}: #{e.message}")
        nil
      end
    end
  end
end
