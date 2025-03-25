Rails.application.routes.draw do
  resources :attendances
  resources :students
  get "home/index"
  resource :session, only: [ :new, :create, :destroy ]
  resources :passwords, param: :token
  resources :signup, only: %i[new create]
  resources :students
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  get "qrcodes", to: "qrcodes#show"  # Updated route for the QR code
  get "scan_qr", to: "qrcodes#scan"

  resources :users, only: [ :index, :show, :edit, :update, :new, :create ]
end
