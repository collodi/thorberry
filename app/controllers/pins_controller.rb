class PinsController < ApplicationController
  before_action :check_priv!

  def index
  end

  def show
    @stage = params[:stage]
    @from = params[:from]

    pv = Pin.find_by(stage: @stage, from: @from)
    @module = if pv.nil? then Settings.default_module else pv[:module] end
    @pins = Settings.pin_descriptions
    @pinval = (if pv.nil? then [] else pv.pinval end)
  end

  def set_pins
    param = params.require(:config_pins).permit(:stage, :from, :module, pinval: [])
    pinval = (param[:pinval] || []).map(&:to_i)

    edit = Pin.find_or_initialize_by(stage: param[:stage], from: param[:from])
    edit.module = param[:module]
    edit.pinval = pinval
    edit.save

    redirect_to pins_path, notice: "Configuration Saved."
  end
end
