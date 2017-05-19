ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def set_gpio_pins(stage, from, pins)
    gpios = Settings.pin_descriptions.gpio
    pnums = pins.map { |p| gpios.index("GPIO%02d" % p) }
    Pin.new(stage: stage, from: from, pinval: pnums, module: 'gpio').save
  end

  def set_piface_pins(stage, from, pins)
    Pin.new(stage: stage, from: from, pinval: pins, module: 'piface').save
  end

  def gpio_output_and_wait(expect)
    Rake::Task['scripts:executor'].execute

    puts 'Expected:'
    expect.each { |p| puts "GPIO%02d" % p }
    puts '==='
    puts 'Correct? (y/N)'
    assert STDIN.gets[0].downcase == 'y', 'Test Failed.'
  end

end
