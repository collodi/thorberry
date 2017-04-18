class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected
  def authenticate_user!
    redirect_to login_path if session[:priv].nil?
  end

  def check_priv!
    unless session[:priv] then
      redirect_to status_path, notice: 'You are not worthy enough.'
    end
  end
end
