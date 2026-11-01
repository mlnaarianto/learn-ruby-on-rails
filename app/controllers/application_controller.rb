# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  helper_method :current_user, :user_signed_in?

  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  private

  # Pundit otomatis memakai current_user sebagai `user` di policy
  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def user_signed_in? = current_user.present?

  def authenticate_user!
    return if user_signed_in?

    redirect_to login_path, alert: "Silakan login terlebih dahulu."
  end

  # Tampilkan pesan, lalu kembali. Hindari redirect loop jika halaman asal
  # juga terlarang (referer sama dengan halaman sekarang).
  def forbidden
    flash[:alert] = "Anda tidak punya akses untuk aksi ini."

    if request.referer.present? && request.referer != request.url
      redirect_back fallback_location: dashboard_path
    elsif request.path == dashboard_path
      redirect_to root_path
    else
      redirect_to dashboard_path
    end
  end
end