module Api
  module V1
    class WishesController < ApplicationController
      skip_before_action :doorkeeper_authorize!, only: [:user_wishes]

      def user_wishes
        render json: wishes_repo.filter({ user_id: params[:user_id], state: :active }, order: params[:o], page: params[:page],
                                                                                        per_page: params[:per_page])
      end

      def realised_user_wishes
        render json: wishes_repo.filter({ user_id: params[:user_id], state: :realised }, order: params[:o], page: params[:page],
                                                                                         per_page: params[:per_page])
      end

      def show
        render json: wish
      end

      def create
        render json: Wishes::Create.call(user_id: current_user.id, wish: wish_params)
      end

      def update
        render json: wish_factory.update(params[:id], wish_params)
      end

      def destroy
        render json: wish_factory.destroy(wish.id)
      end

      def realise
        @wish = Wishes::Realise.call(wish_id: wish.id)
        render json: wish
      end

      def book
        @wish = wish_factory.book(wish_id: wish.id, booker_id: current_user.id)
        render json: wish
      end

      def unbook
        @wish = wish_factory.unbook(wish_id: wish.id, booker_id: current_user.id)
        render json: wish
      end

      private

      def wish
        @wish ||= wish_factory.find(params[:id])
      end

      def current_user_wishes_repo
        @current_user_wishes_repo ||= WishesRepository.new(gateway: current_user.wishes)
      end

      def wishes_repo
        @wishes_repo ||= RepositoryRegistry.for(:wishes)
      end

      def wish_factory
        @wish_factory ||= FactoryRegistry.for(:wish)
      end

      def wish_params
        params.require(:wish).permit(%i[body url])
      end
    end
  end
end
