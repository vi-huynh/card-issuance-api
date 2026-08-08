Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  get "health_check", to: "health_check#index"
  namespace :v1 do
    post "login", to: "sessions#create"
  end
end
