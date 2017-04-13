class StatusController < ApplicationController
  def index
    @status = Status.last
  end
end
