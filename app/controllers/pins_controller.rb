class PinsController < ApplicationController
  before_action :check_priv!

  def index
  end

  def show
    @pins = Settings.pin_descriptions
    @stage = params[:stage]
    @path = params[:path]

    pv = Pin.find_by(stage: @stage, path: @path)
    @pinval = (if pv.nil? then [] else pv.pinval end)
  end

  def set_pins
    param = params.require(:config_pins).permit(:stage, :path, pinval: [])

    edit = Pin.find_or_initialize_by(stage: param[:stage], path: param[:path])
    edit.pinval = param[:pinval]
    edit.save

    redirect_to pins_path, notice: "Configuration Saved."
  end
end
