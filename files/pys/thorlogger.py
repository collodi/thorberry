from thorberry import Thorberry
import json, threading, sys, os, time

class Thorlogger:
	log_dir = '/home/pi/logs/'
	conf_dir = '/home/pi/confs/'

	def __enter__(self):
		script_dir = os.path.dirname(__file__)
                if script_dir:
			os.chdir(script_dir)
		with open(self.conf_dir + 'thorlogger.conf') as f:
			self.conf = json.load(f)

		self.thor = Thorberry()

		if not os.path.exists(self.log_dir):
			os.makedirs(self.log_dir)

		# delete old log files
		del_logs = os.listdir(self.log_dir)
		del_logs.sort()
		for dl in del_logs[:-self.conf['log_file_max']]:
			os.remove(self.log_dir + dl)

		self.state = 0
		self.started = False
		self.timer()
		return self

	def dict_to_p(self, d, delim):
		l = [str(k) + ': ' + str(d[k]) for k in d]
		return delim.join(l)

	def timer(self):
		res_dict = self.thor.get()
		while not res_dict:
			res_dict = self.thor.get()

		# date yyyy-mm-dd format for sorting purpose
		date = res_dict['localtime'][-4:] + '-' + res_dict['localtime'][-10:-5].replace('/', '-')
		fn = self.log_dir + date + '.log'
		if not self.started:
			self.write_line(fn, '*** Thorlogger started ***', 'a')
			self.write_line(fn, self.dict_to_p(res_dict, self.conf['delimiter']), 'a')
			self.started = True
		elif self.state != res_dict['state'] or not os.path.isfile(fn): # state change
			self.write_line(fn, self.dict_to_p(res_dict, self.conf['delimiter']), 'a')
		self.state = res_dict['state']
		# log last checked
		self.write_line('/home/pi/last_checked.txt', json.dumps(res_dict), 'w')
		time.sleep(self.conf['interval'])
		self.timer()

	def write_line(self, filename, line, append):
		if isinstance(line, list):
			line = ' '.join(line)
		with open(filename, append) as f:
			f.write(line + '\n')

	def __exit__(self, t, v, tb):
		self.thor.close()

if __name__ == '__main__':
	while True:
		try:
			with Thorlogger() as tl:
				while True:
					pass
		except KeyboardInterrupt:
			break
		except Exception as e:
                        with open('/home/pi/thor.err', 'w') as f:
                                f.write(e)
