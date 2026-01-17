module Api
  module V1
    class WishesController < ApplicationController
      skip_before_action :doorkeeper_authorize!, only: [:user_wishes]

      def user_wishes
        result = ::Wishes::Queries::ListWishes.call(
          filters: { user_id: params[:user_id], state: :active },
          order: params[:o] || 'created_at desc',
          page: params[:page],
          per_page: params[:per_page]
        )

        render_result(result)
      end

      def realised_user_wishes
        result = ::Wishes::Queries::ListWishes.call(
          filters: { user_id: params[:user_id], state: :realised },
          order: params[:o] || 'created_at desc',
          page: params[:page],
          per_page: params[:per_page]
        )

        render_result(result)
      end

      def index
        result = ::Wishes::Queries::ListWishes.call(
          filters: { user_id: current_user.id, state: :active },
          order: params[:o] || 'created_at desc',
          page: params[:page],
          per_page: params[:per_page]
        )

        render_result(result)
      end

      def show
        result = ::Wishes::Queries::FindWish.call(id: params[:id])
        render_result(result)
      end

      def create
        result = ::Wishes::Create.call(user_id: current_user.id, wish: wish_params)
        render_result(result, status: :created)
      end

      def update
        result = ::Wishes::Commands::UpdateWish.call(
          id: params[:id],
          **wish_params.to_h.symbolize_keys
        )
        render_result(result)
      end

      def destroy
        result = ::Wishes::Commands::DeleteWish.call(id: params[:id])

        if result.success?
          render json: {}, status: :ok
        else
          render_error(result.failure)
        end
      end

      def realise
        result = ::Wishes::Realise.call(wish_id: params[:id])
        render_result(result)
      end

      def book
        result = ::Wishes::Commands::BookWish.call(
          wish_id: params[:id],
          booker_id: current_user.id
        )
        render_result(result)
      end

      def unbook
        result = ::Wishes::Commands::UnbookWish.call(
          wish_id: params[:id],
          booker_id: current_user.id
        )
        render_result(result)
      end

      private

      def wish_params
        params.expect(wish: [%i[body url]])
      end

      def render_result(result, status: :ok)
        if result.success?
          data = result.value!

          # Handle pagination
          if data.is_a?(Hash) && data.key?(:data)
            render json: {
              data: WishSerializer.collection(data[:data]),
              metadata: data[:metadata]
            }, status: status
          elsif data.is_a?(Array)
            render json: WishSerializer.collection(data), status: status
          else
            render json: WishSerializer.new(data).as_json, status: status
          end
        else
          render_error(result.failure, status: :unprocessable_entity)
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
