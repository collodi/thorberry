from thorgpio import ThorGPIO
from thorface import ThorFace

if __name__ == '__main__':
	gpio = ThorGPIO()
        face = ThorFace()
	states = [0, 1, 2, 3, 2, 1, 0]
	index = 0
	try:
		while True:
			raw_input('Waiting Input... ' + str(states[index]))
			gpio.update(states[index])
                        face.update(states[index])
			index = (index + 1) % len(states)
	except:
		gpio.close()
                face.close()
