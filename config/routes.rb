Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  mount_devise_token_auth_for 'User', at: 'auth'

  post 'xaman/request_signin', to: 'xaman_auth#request_signin'
  post 'xaman/verify_signin', to: 'xaman_auth#verify_signin'

  resource :profile, only: [:show, :update]
  post 'validations/check_uniqueness', to: 'validations#check_uniqueness'

  resources :borrow_requests, only: [:create, :index]
end
