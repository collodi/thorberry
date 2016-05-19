import requests, xmltodict, json, os
from thorgpio import ThorGPIO
from thorface import ThorFace

class Thorberry:
	conf_dir = '/home/pi/confs/'

	def __init__(self):
		script_dir = os.path.dirname(__file__)
		os.chdir(script_dir)

		with open(self.conf_dir + 'thorberry.conf') as f:
			self.conf = json.load(f)

		self.gpio = ThorGPIO()
                self.face = ThorFace()

	def get(self):
		header = { 'Host': self.conf['host'] }
		res = requests.get(self.conf['url'] + self.conf['get'], headers=header)

		if res.status_code != 200:
			return None

		data = xmltodict.parse(res.text)
		for dp in self.conf['data_path']:
			data = data[dp]

		result = {}
		for n in self.conf['needed']:
			result[n] = data[n]
		result['state'] = self.conf['levels'].index(result[self.conf['needed'][0]])

		# gpio
		self.gpio.update(result['state'])
                self.face.update(result['state'])

		return result

	def close(self):
		self.gpio.close()
                self.face.close()
