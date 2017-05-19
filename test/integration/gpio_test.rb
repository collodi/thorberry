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

  def self.test_order
    :alpha
  end

  test "0 gpio setup" do
    Pin.delete_all
    set_gpio_pins('AllClear', 'All', pinvals[0])
    set_gpio_pins('Caution', 'AllClear', pinvals[1])
    set_gpio_pins('Warning', 'AllClear', pinvals[2])
    set_gpio_pins('RedAlert', 'All', pinvals[3])
    set_gpio_pins('Warning', 'RedAlert', pinvals[4])
    set_gpio_pins('Caution', 'RedAlert', pinvals[5])
  end

  test "1 AllClear gpio" do
    Status.delete_all
    Status.new(alert: 'AllClear').save
    gpio_output_and_wait(pinvals[0])
  end

  test "2 Caution (From AllClear) gpio" do
    Status.delete_all
    Status.new(alert: 'AllClear').save
    Status.new(alert: 'Caution').save
    gpio_output_and_wait(pinvals[1])
  end

  test "3 Warning (From AllClear) gpio" do
    Status.delete_all
    Status.new(alert: 'AllClear').save
    Status.new(alert: 'Caution').save
    Status.new(alert: 'Warning').save
    gpio_output_and_wait(pinvals[2])
  end

  test "4 Caution (From AllClear & descend) gpio" do
    Status.delete_all
    Status.new(alert: 'AllClear').save
    Status.new(alert: 'Caution').save
    Status.new(alert: 'Warning').save
    Status.new(alert: 'Caution').save
    gpio_output_and_wait(pinvals[1])
  end

  test "5 RedAlert gpio" do
    Status.delete_all
    Status.new(alert: 'AllClear').save
    Status.new(alert: 'Caution').save
    Status.new(alert: 'Warning').save
    Status.new(alert: 'Caution').save
    Status.new(alert: 'RedAlert').save
    gpio_output_and_wait(pinvals[3])
  end

  test "6 Warning (From RedAlert) gpio" do
    Status.delete_all
    Status.new(alert: 'RedAlert').save
    Status.new(alert: 'Warning').save
    gpio_output_and_wait(pinvals[4])
  end

  test "7 Caution (From RedAlert) gpio" do
    Status.delete_all
    Status.new(alert: 'RedAlert').save
    Status.new(alert: 'Warning').save
    Status.new(alert: 'Caution').save
    gpio_output_and_wait(pinvals[5])
  end

  test "8 Warning (From RedAlert & ascend) gpio" do
    Status.delete_all
    Status.new(alert: 'RedAlert').save
    Status.new(alert: 'Warning').save
    Status.new(alert: 'Caution').save
    Status.new(alert: 'Warning').save
    gpio_output_and_wait(pinvals[4])
  end

  test "9 AllClear (From RedAlert) gpio" do
    Status.delete_all
    Status.new(alert: 'RedAlert').save
    Status.new(alert: 'AllClear').save
    gpio_output_and_wait(pinvals[0])
  end

end
