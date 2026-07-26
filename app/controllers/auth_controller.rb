# app/controllers/auth_controller.rb
class AuthController < ApplicationController
  layout "auth"

  # Render halaman login (app/views/auth/login.html.erb)
  def login
  end

  def omniauth
    user = OauthAuthenticationService.call(request.env['omniauth.auth'])
    
    if user
      session[:user_id] = user.id 
      redirect_to dashboard_path, notice: "Berhasil login sebagai #{user.name}!"
    else
      redirect_to login_path, alert: "Gagal memproses data dari Google."
    end
  end

  def failure
    redirect_to login_path, alert: "Proses autentikasi dibatalkan."
  end

  def destroy
    session[:user_id] = nil 
    redirect_to login_path, notice: "Kamu berhasil logout."
  end
end