import time
from thorgpio import ThorGPIO
from thorface import ThorFace

if __name__ == '__main__':
	gpio = ThorGPIO()
        face = ThorFace()
	states = [0, 1, 2, 3, 2, 1, 0]
	try:
		for index in states:
			gpio.update(states[index])
                        face.update(states[index])
                        time.sleep(5)
	except:
		gpio.close()
                face.close()
