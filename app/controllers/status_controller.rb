class StatusController < ApplicationController
  def index
    @status = Status.last
  end

  def logs

  end
end
