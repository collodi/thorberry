import json, os
import RPi.GPIO as gpio

class ThorGPIO:
	conf_dir = '/home/pi/confs/'

	def __init__(self):
		script_dir = os.path.dirname(__file__)
		os.chdir(script_dir)

		self.state = 0
		self.on = None
		with open(self.conf_dir + 'thorgpio.conf', 'r') as f:
			self.conf = json.load(f)
		self.conf['level_pin'] = [int(i) for i in self.conf['level_pin']]

		self.pinoffs = {}
		for i in set(self.conf['level_pin']):
			if not i:
				continue
			self.pinoffs[abs(i)] = 1 if i < 0 else 0

		gpio.setmode(gpio.BCM)
		gpio.setup(self.pinoffs.keys(), gpio.OUT)
		self.reset_pins()

	def reset_pins(self):
		gpio.output(self.pinoffs.keys(), self.pinoffs.values())

	def update(self, state):
		if self.state == state:
			return

		tmp = state
		if self.state > state:
			state = -state - 1
		self.state = tmp

		pin = abs(self.conf['level_pin'][state])
		if self.on != pin:
			self.reset_pins()
			self.on = pin
			if pin:
				gpio.output(pin, not self.pinoffs[pin])

	def close(self):
		gpio.cleanup()
