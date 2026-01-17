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
     resources :users, only: %i(index show update)
   end
 end
end
