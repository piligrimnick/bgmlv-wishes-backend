module Wishes
  class PrepareFromText < ApplicationService
    USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'.freeze

    param :text

    def call
      url = Utils::ParseUrl.call(text: text)

      return { body: text, url: nil } if url.blank?

      metadata = MetaInspector.new(
        url,
        allow_redirections: false,
        allow_non_html_content: true,
        download_images: false,
        headers: { 'User-Agent' => USER_AGENT }
      )

      return { body: text, url: url } if metadata.response.status != 200

      body = text.gsub(url, '').to_s
      body += "\n\n"
      body += metadata.best_title.to_s
      body += "\n\n"
      body += metadata.best_description.to_s
      
      body = body.strip
      body = text if body.blank?

      {
        body:,
        url: metadata.canonicals.first&.dig(:href) || url,
        picture: Utils::DownloadImage.call(url: metadata.images.best)
      }
    rescue MetaInspector::RequestError => e
      {
        body: text,
        url: url
      }
    end
  end
end
