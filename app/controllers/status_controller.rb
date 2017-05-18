class StatusController < ApplicationController
  before_action :authenticate_user!

  def index
    @status = Status.last
  end

  def logs
    @defaults = { start_date: Time.now.strftime("%F"), end_date: Time.now.strftime("%F") }
  end

  def save_logs
    dates = params.require(:date_range).permit(:start_date, :end_date)
    @logs = Status.where(created_at: Time.parse(dates[:start_date])...(Time.parse(dates[:end_date]) + 1.day))
    
    send_data(@logs.to_json, filename: 'thorberry_log.txt')
  end

  def fetch_logs
    dates = params.require(:date_range).permit(:start_date, :end_date)
    @logs = Status.where(created_at: Time.parse(dates[:start_date])...(Time.parse(dates[:end_date]) + 1.day))
    @defaults = dates

    render :logs
  end

  def logout
    session.delete(:priv)
    redirect_to login_path
  end
end
