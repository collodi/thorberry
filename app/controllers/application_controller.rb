class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected
  def authenticate_user!
    (redirect_to login_path and true) if session[:priv].nil?
  end

  def check_priv!
    authenticate_user! and return
    unless session[:priv] then
      redirect_to status_path, notice: 'You are not worthy.'
    end
  end
end
