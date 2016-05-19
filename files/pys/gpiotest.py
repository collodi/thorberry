import time
from thorgpio import ThorGPIO
from thorface import ThorFace

if __name__ == '__main__':
	gpio = ThorGPIO()
        face = ThorFace()
	states = [0, 1, 2, 3, 2, 1, 0]
	index = 0
	try:
		while True:
			gpio.update(states[index])
                        face.update(states[index])
			index = (index + 1) % len(states)
                        time.sleep(5)
	except:
		gpio.close()
                face.close()
