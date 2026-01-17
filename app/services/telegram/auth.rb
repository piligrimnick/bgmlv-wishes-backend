module Telegram
  class Auth < ApplicationService
    option :auth_data
    option :secure_hash

    def call
      user if check_hash == secure_hash
    end

    private

    def user
      @user ||= Users::Commands::FindOrCreateFromTelegram.call(
        chat_id: auth_data['id'],
        username: auth_data['username'],
        firstname: auth_data['first_name'],
        lastname: auth_data['last_name']
      )
    end

    def check_hash
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret_key, data_string)
    end

    def data_string
      auth_data.sort.map { |v| v.join('=') }.join("\n")
    end

    def secret_key
      OpenSSL::Digest.new('SHA256').digest(ENV.fetch('TELEGRAM_TOKEN', nil))
    end
  end
end
