Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  get "health_check", to: "health_check#index"
  namespace :v1 do
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    namespace :admin do
      resources :brands, only: [ :index, :create, :show ]
    end
  end
end
