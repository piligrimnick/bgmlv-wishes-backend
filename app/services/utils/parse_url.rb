module Utils
  class ParseUrl < ApplicationService
    option :text

    def call
      return nil if text.blank?

      URI.extract(text).first
    end
  end
end
