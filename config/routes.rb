Rails.application.routes.draw do
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

  # Subscription management
  resources :subscriptions do
    member do
      patch :cancel
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
