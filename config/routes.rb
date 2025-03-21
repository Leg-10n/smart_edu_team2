Rails.application.routes.draw do
  namespace :admin do
    get "subscriptions/index"
    get "subscriptions/show"
  end
  get "subscriptions/index"
  get "subscriptions/show"
  get "subscriptions/new"
  get "subscriptions/create"
  get "payments/new"
  get "payments/create"
  get "payments/show"
  resources :attendances
  resources :students
  get "home/index"
  resource :session
  resources :passwords, param: :token
  resources :signup, only: %i[new create]
  resources :students
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  get "qrcodes", to: "qrcodes#show"  # Updated route for the QR code
  get "scan_qr", to: "qrcodes#scan"

  resources :users, only: [ :index, :show, :edit, :update, :new, :create ]
  resources :subscriptions, only: [ :index, :new, :create, :show ]
  resources :payments, only: [ :new, :create, :show ]
  get "payment_success", to: "payments#success"
  get "payment_failure", to: "payments#failure"

  resources :subscriptions, only: [ :index, :new, :create, :show ] do
    post "cancel", on: :member
  end
  resources :payments, only: [ :new, :create, :show ]
  get "payment_success", to: "payments#success"
  get "payment_failure", to: "payments#failure"
  post "omise_webhook", to: "payments#webhook"

  namespace :admin do
    resources :subscriptions, only: [ :index, :show ] do
      post "extend", on: :member
    end
  end

  resources :subscriptions, only: [ :index, :new, :create, :show ] do
    post "cancel", on: :member
  end

  resources :payments, only: [ :new, :create, :show ]
  get "payment_success", to: "payments#success"
  get "payment_failure", to: "payments#failure"
  post "omise_webhook", to: "payments#webhook"
end
