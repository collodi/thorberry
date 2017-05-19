require 'test_helper'

class GpioTest < ActionDispatch::IntegrationTest
  pinvals = [
    [],
    [2, 3],
    [3, 4],
    [5, 6],
    [7, 8],
    [8, 9]
  ]

  test "gpio" do
    Pin.delete_all
    set_gpio_pins('AllClear', 'All', pinvals[0])
    set_gpio_pins('Caution', 'AllClear', pinvals[1])
    set_gpio_pins('Warning', 'AllClear', pinvals[2])
    set_gpio_pins('RedAlert', 'All', pinvals[3])
    set_gpio_pins('Warning', 'RedAlert', pinvals[4])
    set_gpio_pins('Caution', 'RedAlert', pinvals[5])
    puts 'db initialized'

    Status.delete_all

    puts "=== AllClear gpio"
    Status.new(alert: 'AllClear').save
    gpio_output_and_wait(pinvals[0])

    puts "=== Caution (From AllClear)"
    Status.new(alert: 'Caution').save
    gpio_output_and_wait(pinvals[1])

    puts "=== Warning (From AllClear)"
    Status.new(alert: 'Warning').save
    gpio_output_and_wait(pinvals[2])

    puts "=== Caution (From AllClear & descend)"
    Status.new(alert: 'Caution').save
    gpio_output_and_wait(pinvals[1])

    puts "=== RedAlert"
    Status.new(alert: 'RedAlert').save
    gpio_output_and_wait(pinvals[3])

    puts "=== Warning (From RedAlert)"
    Status.new(alert: 'Warning').save
    gpio_output_and_wait(pinvals[4])

    puts "=== Caution (From RedAlert)"
    Status.new(alert: 'Caution').save
    gpio_output_and_wait(pinvals[5])

    puts "=== Warning (From RedAlert & ascend)"
    Status.new(alert: 'Warning').save
    gpio_output_and_wait(pinvals[4])

    puts "=== AllClear (From RedAlert)"
    Status.new(alert: 'AllClear').save
    gpio_output_and_wait(pinvals[0])
  end

end
