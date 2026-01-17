module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :doorkeeper_authorize!, only: %i[index show]

      def index
        result = ::Users::Queries::ListUsers.call(
          page: params[:page],
          per_page: params[:per_page]
        )

        render_result(result, secure: false)
      end

      def show
        result = ::Users::Queries::FindUser.call(id: params[:id])

        if result.success?
          user = result.value!
          secure = current_resource_owner&.id.to_s == params[:id].to_s
          render json: UserSerializer.new(user).as_json(secure: secure)
        else
          render_error(result.failure)
        end
      end

      def update
        if current_resource_owner.id.to_s != params[:id].to_s
          render json: { error: 'Forbidden' }, status: :forbidden
          return
        end

        result = ::Users::Commands::UpdateUser.call(
          id: params[:id],
          **user_params.to_h.symbolize_keys
        )

        if result.success?
          render json: UserSerializer.new(result.value!).as_json(secure: true)
        else
          render_error(result.failure)
        end
      end

      # GET /api/v1/users/search?q=john
      def search
        result = ::Friendships::Queries::SearchUsers.call(
          query: params[:q],
          current_user_id: current_user.id,
          page: params[:page],
          per_page: params[:per_page]
        )

        if result.success?
          data = result.value!

          # Enrich with friendship status
          users_with_status = if data.is_a?(Hash) && data.key?(:data)
            enrich_users_with_friendship_status(data[:data])
          else
            enrich_users_with_friendship_status(data)
          end

          if data.is_a?(Hash) && data.key?(:metadata)
            render json: {
              data: users_with_status,
              metadata: data[:metadata]
            }
          else
            render json: users_with_status
          end
        else
          render_error(result.failure)
        end
      end

      private

      def enrich_users_with_friendship_status(users)
        user_ids = users.map(&:id)

        # Batch fetch all friendships
        friendships = Friendship.where(
          requester_id: [current_user.id, *user_ids],
          addressee_id: [current_user.id, *user_ids]
        ).to_a

        users.map do |user|
          friendship = friendships.find do |f|
            (f.requester_id == current_user.id && f.addressee_id == user.id) ||
            (f.requester_id == user.id && f.addressee_id == current_user.id)
          end

          user_json = UserSerializer.new(user).as_json(secure: false)

          if friendship.nil?
            user_json[:friendship_status] = 'none'
          elsif friendship.requester_id == current_user.id
            user_json[:friendship_status] = "outgoing_#{friendship.status}"
          else
            user_json[:friendship_status] = "incoming_#{friendship.status}"
          end

          user_json
        end
      end

      def user_params
        params.expect(user: %i[email password firstname lastname])
      end

      def render_result(result, secure: false)
        if result.success?
          data = result.value!

          # Handle pagination
          if data.is_a?(Hash) && data.key?(:data)
            render json: {
              data: UserSerializer.collection(data[:data], secure: secure),
              metadata: data[:metadata]
            }
          elsif data.is_a?(Array)
            render json: UserSerializer.collection(data, secure: secure)
          else
            render json: UserSerializer.new(data).as_json(secure: secure)
          end
        else
          render_error(result.failure)
        end
      end

      def render_error(error, status: :unprocessable_entity)
        case error
        when :not_found
          render json: { error: 'Not found' }, status: :not_found
        when ActiveModel::Errors
          render json: { errors: error }, status: status
        else
          render json: { error: error }, status: status
        end
      end
    end
  end
end
