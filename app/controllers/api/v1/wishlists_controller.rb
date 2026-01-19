module Api
  module V1
    class WishlistsController < ApplicationController
      # Public read access is allowed, but private wishlists require auth+friendship.
      skip_before_action :doorkeeper_authorize!, only: %i[user_wishlists show wishes]

      # GET /api/v1/users/:user_id/wishlists
      # unauthenticated: only public
      # authenticated non-friend: only public
      # friend/owner: public + private
      def user_wishlists
        result = ::Wishlists::Queries::ListUserWishlists.call(
          user_id: params[:user_id],
          viewer_id: current_user&.id
        )

        if result.success?
          render json: WishlistSerializer.collection(result.value!), status: :ok
        else
          render_error(result.failure, status: :unprocessable_entity)
        end
      end

      # POST /api/v1/wishlists
      def create
        wishlist_params = params.expect(wishlist: %i[title]).merge(params.permit(wishlist: %i[description visibility])[:wishlist] || {})
        results_params = { name: wishlist_params[:title] }
        results_params[:description] = wishlist_params[:description] if wishlist_params[:description].present?
        results_params[:visibility] = wishlist_params[:visibility] if wishlist_params[:visibility].present?

        result = ::Wishlists::Commands::CreateWishlist.call(
          user_id: current_user.id,
          **results_params.symbolize_keys
        )

        if result.success?
          render json: WishlistSerializer.new(result.value!).as_json, status: :created
        else
          render_error(result.failure, status: :unprocessable_entity)
        end
      end

      # PUT /api/v1/wishlists/:id
      def update
        wishlist_params = params.permit(:title, :description, :visibility).to_h
        wishlist_params['name'] = wishlist_params.delete('title') if wishlist_params.key?('title')
        result = ::Wishlists::Commands::UpdateWishlist.call(
          id: params[:id],
          user_id: current_user.id,
          **wishlist_params.symbolize_keys
        )

        if result.success?
          render json: WishlistSerializer.new(result.value!).as_json, status: :ok
        else
          render_error(result.failure, status: :unprocessable_entity)
        end
      end

      # DELETE /api/v1/wishlists/:id
      def destroy
        confirm_param = params[:confirm] || params.dig(:confirm)
        result = ::Wishlists::Commands::DeleteWishlist.call(
          id: params[:id],
          user_id: current_user.id,
          confirm: confirm_param == 'true' || confirm_param == true
        )

        if result.success?
          head :no_content
        else
          render_error(result.failure, status: :unprocessable_entity)
        end
      end

      # GET /api/v1/wishlists/:id
      def show
        wishlist_result = ::Wishlists::Queries::FindWishlist.call(id: params[:id])
        return render_error(:not_found, status: :not_found) if wishlist_result.failure?

        wishlist = wishlist_result.value!

        visibility = ::Wishlists::Queries::CheckWishlistVisibility.call(
          wishlist: wishlist,
          viewer_id: current_user&.id
        )

        unless visibility.success? && visibility.value!
          return render_error(:not_found, status: :not_found)
        end

        render json: WishlistSerializer.new(wishlist).as_json, status: :ok
      end

      # GET /api/v1/wishlists/:id/wishes
      # Returns all wishes (no filtering by realised/active)
      def wishes
        wishlist_result = ::Wishlists::Queries::FindWishlist.call(id: params[:id])
        return render_error(:not_found, status: :not_found) if wishlist_result.failure?

        wishlist = wishlist_result.value!

        visibility = ::Wishlists::Queries::CheckWishlistVisibility.call(
          wishlist: wishlist,
          viewer_id: current_user&.id
        )

        unless visibility.success? && visibility.value!
          return render_error(:not_found, status: :not_found)
        end

        wishes_result = ::Wishes::Queries::ListWishlistWishes.call(wishlist_id: wishlist.id)
        return render_error(wishes_result.failure, status: :unprocessable_entity) if wishes_result.failure?

        render json: WishSerializer.collection(wishes_result.value!), status: :ok
      end

      private

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
