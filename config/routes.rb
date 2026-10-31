Rails.application.routes.draw do
  # Health check bawaan Rails
  get "up" => "rails/health#show", as: :rails_health_check

  # 1. RUTE HALAMAN UTAMA (ROOT / HOME)
  root "home#index"
  get "/home", to: "home#index"

  # 2. RUTE DASHBOARD
  get "/dashboard", to: "dashboard#index"

  # 3. RUTE AUTENTIKASI & SESI
  get    "/login",    to: "auth#login",       as: :login
  post   "/login",    to: "auth#authenticate"
  get    "/register", to: "auth#register",    as: :register
  post   "/register", to: "auth#create"
  delete "/logout",   to: "auth#destroy",     as: :logout

  # 4. RUTE OMNIAUTH (GOOGLE CALLBACK)
  get "/auth/:provider/callback", to: "auth#omniauth"
  get "/auth/failure",            to: "auth#failure"
end