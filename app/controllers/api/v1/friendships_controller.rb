module Api
  module V1
    class FriendshipsController < ApplicationController
      # All actions require authentication (no skip_before_action)

      # POST /api/v1/friendships (Send friend request)
      def create
        result = ::Friendships::Commands::SendFriendRequest.call(
          requester_id: current_user.id,
          addressee_id: params[:addressee_id]
        )

        if result.success?
          render json: FriendshipSerializer.new(result.value!).as_json, status: :created
        else
          render_friendship_error(result.failure)
        end
      end

      # GET /api/v1/friendships (List current user's friends)
      def index
        result = ::Friendships::Queries::ListFriends.call(
          user_id: current_user.id,
          page: params[:page],
          per_page: params[:per_page]
        )
        render_result(result)
      end

      # GET /api/v1/friendships/incoming (Incoming friend requests)
      def incoming
        result = ::Friendships::Queries::ListIncomingRequests.call(
          user_id: current_user.id,
          page: params[:page],
          per_page: params[:per_page]
        )

        if result.success?
          data = result.value!
          if data.is_a?(Hash) && data.key?(:data)
            render json: {
              data: FriendshipSerializer.collection(data[:data]),
              metadata: data[:metadata]
            }
          else
            render json: FriendshipSerializer.collection(data)
          end
        else
          render json: { error: result.failure }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/friendships/outgoing (Outgoing friend requests)
      def outgoing
        result = ::Friendships::Queries::ListOutgoingRequests.call(
          user_id: current_user.id,
          page: params[:page],
          per_page: params[:per_page]
        )

        if result.success?
          data = result.value!
          if data.is_a?(Hash) && data.key?(:data)
            render json: {
              data: FriendshipSerializer.collection(data[:data]),
              metadata: data[:metadata]
            }
          else
            render json: FriendshipSerializer.collection(data)
          end
        else
          render json: { error: result.failure }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/friendships/:id/accept
      def accept
        result = ::Friendships::Commands::AcceptFriendRequest.call(
          friendship_id: params[:id],
          addressee_id: current_user.id
        )

        if result.success?
          render json: FriendshipSerializer.new(result.value!).as_json
        else
          render_friendship_error(result.failure)
        end
      end

      # PUT /api/v1/friendships/:id/reject
      def reject
        result = ::Friendships::Commands::RejectFriendRequest.call(
          friendship_id: params[:id],
          addressee_id: current_user.id
        )

        if result.success?
          render json: FriendshipSerializer.new(result.value!).as_json
        else
          render_friendship_error(result.failure)
        end
      end

      # DELETE /api/v1/friendships/:id/cancel (Cancel pending request)
      def cancel
        result = ::Friendships::Commands::CancelFriendRequest.call(
          friendship_id: params[:id],
          requester_id: current_user.id
        )

        if result.success?
          render json: {}, status: :ok
        else
          render_friendship_error(result.failure)
        end
      end

      # DELETE /api/v1/friendships/:id (Remove friendship)
      def destroy
        result = ::Friendships::Commands::RemoveFriendship.call(
          friendship_id: params[:id],
          user_id: current_user.id
        )

        if result.success?
          render json: {}, status: :ok
        else
          render_friendship_error(result.failure)
        end
      end

      # GET /api/v1/friendships/status/:user_id (Check friendship status with user)
      def status
        result = ::Friendships::Queries::CheckFriendshipStatus.call(
          user_id: current_user.id,
          other_user_id: params[:user_id]
        )

        if result.success?
          render json: result.value!
        else
          render json: { error: result.failure }, status: :unprocessable_entity
        end
      end

      private

      def render_result(result)
        if result.success?
          data = result.value!
          if data.is_a?(Hash) && data.key?(:data)
            render json: {
              data: UserSerializer.collection(data[:data], secure: false),
              metadata: data[:metadata]
            }
          else
            render json: UserSerializer.collection(data, secure: false)
          end
        else
          render json: { error: result.failure }, status: :unprocessable_entity
        end
      end

      def render_friendship_error(error)
        status = case error
                 when :not_found then :not_found
                 when :forbidden then :forbidden
                 when :already_friends, :request_already_sent then :conflict
                 else :unprocessable_entity
                 end

        render json: { error: error }, status: status
      end
    end
  end
end
