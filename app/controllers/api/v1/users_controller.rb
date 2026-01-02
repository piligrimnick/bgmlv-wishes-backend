module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :doorkeeper_authorize!, only: %i[index show]

      def index
        render json: user_repository.all
      end

      def show
        if current_resource_owner&.id.to_s == params[:id].to_s
          render json: user.attributes
        else
          render json: user.secure_attributes
        end
      end

      def update
        if current_resource_owner.id.to_s != params[:id].to_s
          render json: { error: 'Forbidden' }, status: :forbidden
          return
        end

        begin
          updated_user = user_factory.update(params[:id], user_params)
          render json: updated_user.secure_attributes
        rescue ActiveRecord::RecordInvalid => e
          render json: { errors: e.record.errors }, status: :unprocessable_entity
        end
      end

      private

      def user
        @user ||= user_factory.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:email, :password, :firstname, :lastname)
      end

      def user_factory
        @user_factory ||= FactoryRegistry.for(:user)
      end

      def user_repository
        @user_repository ||= RepositoryRegistry.for(:users)
      end
    end
  end
end
