# app/controllers/auth_controller.rb
class AuthController < ApplicationController
  layout "auth"

  # ============ HALAMAN (GET) ============
  # GET /login
  def login
  end

  # GET /register
  def register
  end

  # ============ PROSES LOGIN MANUAL (POST) ============
  # POST /login
  def authenticate
    user = User.find_by(email: params[:email].to_s.downcase.strip)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "Berhasil login sebagai #{user.name}!"
    else
      flash.now[:alert] = "Email atau password salah."
      render :login, status: :unprocessable_entity
    end
  end

# ============ PROSES REGISTER (POST) ============
# POST /register
def create
  if params[:password].blank?
    flash.now[:alert] = "Password wajib diisi."
    return render :register, status: :unprocessable_entity
  end

  user = User.new(register_params)

  if user.save
    # ✅ JANGAN set session di sini → user harus login manual
    redirect_to login_path,
                notice: "Akun berhasil dibuat. Silakan login, #{user.name}!"
  else
    @user = user
    flash.now[:alert] = user.errors.full_messages.to_sentence
    render :register, status: :unprocessable_entity
  end
end

  # ============ OAUTH GOOGLE (tetap) ============
  def omniauth
    user = OauthAuthenticationService.call(request.env["omniauth.auth"])

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

  # ============ LOGOUT ============
  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Kamu berhasil logout."
  end

  private

  def register_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
