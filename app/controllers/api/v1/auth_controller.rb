module Api
  module V1
    class AuthController < Doorkeeper::TokensController
      def create
        response = authorize_response

        # Check if response is an error
        if response.is_a?(Doorkeeper::OAuth::ErrorResponse)
          headers.merge!(response.headers)
          render json: response.body, status: response.status
          return
        end

        result = ::Users::Queries::FindUser.call(id: response.token.resource_owner_id)

        headers.merge!(response.headers)

        if result.success?
          user_data = UserSerializer.new(result.value!).as_json(secure: true)
          render json: response.body.merge(user_data), status: response.status
        else
          render json: { error: 'User not found' }, status: :not_found
        end
      rescue Doorkeeper::Errors::DoorkeeperError => e
        handle_token_exception(e)
      end
    end
  end
end
