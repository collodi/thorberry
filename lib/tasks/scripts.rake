begin
  require 'pi_piper'
rescue
  puts 'warning: pi_piper gem is not loaded (not on RPi?)'
end

begin
  require 'piface'
rescue
  puts 'warning: piface is not loaded (not on RPi?)'
end

namespace :scripts do
  desc "fetches lightning status information"
  task prophet: :environment do
    res = HTTP.get(Settings.asgard)
    (Error.new({ msg: res.reason, code: res.code }).save and next) if res.code != 200

    data = Status.new
    xml = Nokogiri::XML(res.body)
    data[:alert] = xml.xpath('//lightningalert').first.content
    data[:ad] = xml.xpath('//ad').first.content
    data[:di] = xml.xpath('//di').first.content
    data[:lhl] = xml.xpath('//lhl').first.content
    data[:fcc] = xml.xpath('//fcc').first.content

    last = Status.last
    data.save if last != data or last.created_at + 1.hour < Time.now
  end

  desc "changes GPIO or PiFace outputs"
  task executor: :environment do
    # get current status
    curr = Status.last
    from = 'All'
    # get from
    nomems = Pin.where(from: 'All').map { |i| i.stage }
    unless nomems.include? curr.alert then
      tmp = Status.where(alert: Settings.status_checkpoints).last
      from = tmp.alert unless tmp.nil?
    end
    # get pin value configuration
    pinconf = Pin.find_by(stage: curr.alert, from: from)
    next if pinconf.nil?
    # set pins
    if pinconf.module == 'gpio' then
      set_gpio(pinconf.pinval)
    elsif pinconf.module == 'piface' then
      set_piface(pinconf.pinval)
    end
  end

end

def set_gpio(pins)
  gpios = Settings.pin_descriptions.gpio
  gpios.each_index do |i|
    next unless gpios[i].start_with?('GPIO')

    pin = PiPiper::Pin.new(pin: gpios[i][4..-1].to_i, direction: out)
    if pins.includes?(i) then pin.on else pin.off end
  end
end

def set_piface(pins)
  faces = Settings.pin_descriptions.piface
  faces.each_index do |i|
    Piface.write (i + 1), pins.includes?(i)
  end
end
