# config/routes.rb
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
  # Landing page at root
  root "home#landing"

  # Dashboard must be accessed only when logged in
  get "dashboard", to: "home#dashboard"

  # Standard resources
  resources :attendances
  resources :students

  # Session (Login/Logout)
  resource :session

  # Password reset
  resources :passwords, param: :token

  # Signup
  resources :signup, only: %i[new create]

  resources :users, only: [ :index, :show, :edit, :update, :new, :create ]

  # QR code scanning
  get "qrcodes", to: "qrcodes#show"
  get "scan_qr", to: "qrcodes#scan"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # If you want the old route for "home/index", remove it or redirect it; we replaced with "home#dashboard"
  # get "home/index", to: redirect("/dashboard")
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
