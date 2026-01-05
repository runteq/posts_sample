Rails.application.routes.draw do
  root "book_posts#index"

  # 認証
  get    "signup",  to: "users#new"
  post   "signup",  to: "users#create"
  get    "login",   to: "sessions#new"
  post   "login",   to: "sessions#create"
  delete "logout",  to: "sessions#destroy"

  # 書籍投稿
  resources :book_posts do
    resource :like, only: [:create, :destroy]
    resources :comments, only: [:create, :destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
