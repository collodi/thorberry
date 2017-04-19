class LoginController < ApplicationController
  def index
    redirect_to status_path unless session[:priv].nil?
  end

  def auth
    u = params.require(:login).permit(:user, :pwd)
    r = Login.find_by(u)
    if r.nil? then
      redirect_to login_path, :notice => 'Wrong credential.'
    else
      session[:priv] = r.priv
      redirect_to status_path
    end
  end
end
