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

      private

      def user_params
        params.require(:user).permit(:email, :password, :firstname, :lastname)
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
