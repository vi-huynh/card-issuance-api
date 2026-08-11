Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  get "health_check", to: "health_check#index"
  namespace :v1 do
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    namespace :clients do
      resource :password_reset, only: [ :create ]
      resources :products, only: [ :index ]
      resources :cards, only: [ :create ] do
        member do
          patch :cancel
        end
      end
    end

    namespace :admin do
      resources :brands, only: [ :index, :create, :show ] do
        resources :products
      end

      resources :clients, only: [ :index, :create ]

      resources :client_products, only: [ :create, :destroy ]

      resource :report, only: [ :show ], controller: "reports"
    end
  end
end
