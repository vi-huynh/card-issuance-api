Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  get "health_check", to: "health_check#index"
  namespace :v1 do
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    namespace :clients do
      resource :password_reset, only: [ :create ]
    end

    namespace :admin do
      resources :brands, only: [ :index, :create, :show ] do
        resources :products
      end

      resources :clients, only: [ :index, :create ]
    end
  end
end
