Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
    controllers tokens: 'api/v1/auth'
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  scope module: :api, defaults: { format: :json }, path: 'api' do
    scope module: :v1, constraints: Constraints::ApiConstraint.new(version: 1, default: true) do
      devise_for :users, controllers: {
       registrations: 'api/v1/users/registrations',
     }, skip: [:sessions, :password]


     get 'user_wishes/:user_id', to: 'wishes#user_wishes'
     get 'realised_user_wishes/:user_id', to: 'wishes#realised_user_wishes'
     resources :wishes do
       member do
         put :realise
         put :book
         put :unbook
       end
     end

     resources :users, only: %i(index show update) do
       collection do
         get :search
       end
     end

     # Wishlists (read)
     # - GET /api/v1/users/:user_id/wishlists
     # - GET /api/v1/wishlists/:id
     # - GET /api/v1/wishlists/:id/wishes
     resources :wishlists, only: %i[show] do
       member do
         get :wishes
       end
     end

     get 'users/:user_id/wishlists', to: 'wishlists#user_wishlists'

     # Friendships
     resources :friendships, only: [:index, :create, :destroy] do
       collection do
         get :incoming
         get :outgoing
         get 'status/:user_id', action: :status
       end

       member do
         put :accept
         put :reject
         delete :cancel
       end
     end
   end
 end
end
