class StatusController < ApplicationController
  before_filter :authenticate_user!

  def index
    @status = Status.last
  end

  def logs
  end

  def fetch_logs
    dates = params.require(:date_range).permit(:start_date, :end_date)
    @logs = Status.where(created_at: Time.parse(dates[:start_date])...(Time.parse(dates[:end_date]) + 1.day))

    render :logs
  end

  def logout
    session.delete(:priv)
    redirect_to login_path
  end
end
