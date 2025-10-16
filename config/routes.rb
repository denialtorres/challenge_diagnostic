Rails.application.routes.draw do
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :v1 do
    namespace :auth do
      post :login, to: "sessions#create"
      delete :logout, to: "sessions#destroy"
      resources :registrations, only: %i[create]
    end
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
