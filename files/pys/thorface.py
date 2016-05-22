import json, os
import pifacedigitalio as face

class ThorFace:
	conf_dir = '/home/pi/confs/'

	def __init__(self):
		script_dir = os.path.dirname(__file__)
                if script_dir:
			os.chdir(script_dir)

		self.state = 0
		self.on = None
		with open(self.conf_dir + 'thorface.conf', 'r') as f:
			self.conf = json.load(f)
		self.conf['level_pin'] = [int(i) for i in self.conf['level_pin']]

		self.pinoffs = {}
		for i in set(self.conf['level_pin']):
			if not i:
				continue
			self.pinoffs[abs(i)] = 1 if i < 0 else 0

                face.init()
		self.reset_pins()

	def reset_pins(self):
                for i in self.pinoffs.keys():
                        face.digital_write(i - 1, self.pinoffs[i])

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
                                print 'DEBUG: changed ' + (pin - 1) + ' pin to ' + (not self.pinoffs[pin]) + '\n'
                                face.digital_write(pin - 1, not self.pinoffs[pin])

	def close(self):
		pass
