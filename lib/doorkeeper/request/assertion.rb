module Doorkeeper
  module Request
    class Assertion < Strategy
      delegate :credentials, to: :server

      def request
        @request ||= AssertionRequest.new(server, client, resource_owner)
      end

      private

      def client
        return nil unless credentials

        # Doorkeeper::Application.find_by(uid: ...) works for ActiveRecord
        # If credentials.uid is present
        return nil if credentials.uid.blank?

        app = Doorkeeper::Application.find_by(uid: credentials.uid)

        # Validate secret if present. Note: Client Authentication usually handled by `server.credentials` returning valid object IF it validated?
        # Doorkeeper::OAuth::Client::Credentials validates internally if constructed with validation?
        # Usually Strategy just gets credentials.

        # If we trust credentials.secret (it comes from params), we must compare.
        # But for assertion grant (Telegram), client auth might be optional.

        if app && app.secret == credentials.secret
          app
        else
          # If client authentication fails, we should probably fail?
          # Or just treat as public if we support that?
          # For now, if provided but invalid, return nil (fail auth??)
          # If we return nil, it's like no client.
          nil
        end
      end

      def resource_owner
        auth_data = server.parameters[:auth_data]
        return nil unless auth_data

        auth_data_hash = if auth_data.respond_to?(:to_unsafe_h)
                           auth_data.to_unsafe_h
                         else
                           auth_data.to_h
                         end

        result = Telegram::Auth.call(
          auth_data: auth_data_hash.except('hash', :hash),
          secure_hash: auth_data_hash['hash'] || auth_data_hash[:hash]
        )

        if result.respond_to?(:success?) && result.success?
          result.success
        elsif result.respond_to?(:failure?)
          nil
        else
          # Fallback for non-monad return just in case
          result
        end
      end

      class AssertionRequest
        def initialize(server, client, resource_owner)
          @server = server
          @client = client
          @resource_owner = resource_owner
        end

        def authorize
          return Doorkeeper::OAuth::ErrorResponse.new(name: :invalid_grant, state: nil) unless @resource_owner

          # Logic to create access token
          # Note: Doorkeeper::AccessToken is the model

          token = Doorkeeper::AccessToken.create!(
            application_id: @client&.id,
            resource_owner_id: @resource_owner.id,
            expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
            scopes: Doorkeeper.configuration.default_scopes.to_s,
            use_refresh_token: false
          )

          Doorkeeper::OAuth::TokenResponse.new(token)
        end
      end
    end
  end
end
