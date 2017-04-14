require 'http'

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
    data.save if Status.last != data
  end

end
