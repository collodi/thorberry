class StatusController < ApplicationController
  def index
    @status = Status.last
  end

  def log

  end
end
