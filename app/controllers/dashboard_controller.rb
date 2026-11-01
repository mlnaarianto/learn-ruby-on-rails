# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  before_action :authenticate_user!   # cukup login, tanpa permission khusus

  def index
  end
end
