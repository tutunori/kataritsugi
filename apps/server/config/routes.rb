# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  get "register", to: "registrations#new"
  post "register", to: "registrations#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resource :mypage, only: %i[show update], controller: "mypages"

  get "downloads/android", to: "downloads#android", as: :android_download

  namespace :api do
    namespace :v1 do
      get "status" => "status#show"

      scope :auth do
        post "register" => "auth#register"
        post "login" => "auth#login"
        delete "logout" => "auth#logout"
      end

      get "me" => "me#show"
      patch "me" => "me#update"

      resources :recording_sessions, only: %i[index show create] do
        member do
          post :complete
        end
        resources :media_assets, only: %i[create]
      end

      resources :memoirs, only: %i[index show create]
    end
  end

  namespace :admin do
    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"
    resources :users, only: %i[index show]
    root to: "dashboards#show"
  end
end
