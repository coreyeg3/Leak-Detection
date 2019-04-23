#!/usr/bin/env python
#


import sys          
import time
import datetime
import SDL_Pi_HDC1000
from tqdm import tqdm
from influxdb import InfluxDBClient
import numpy as np
import calendar


# Main Program

filename = "/home/pi/humidity/logfiles/"+time.strftime("%Y-%m-%d_%H%M%S")+"_EnviromentLog.txt"

with open(filename, "ax+") as f:
	f.write("time,temperature,humidity \n")
step = 20
rate = 0.0
roicount = 0
roialert = 0
slope = np.zeros(step)
counter=0
while True:
	try:
		hdc1000 = SDL_Pi_HDC1000.SDL_Pi_HDC1000()
        	while True:      
		   #   	with open(filename) as f:
			tim = calendar.timegm(time.gmtime())
			temp = hdc1000.readTemperature()
			humidity = hdc1000.readHumidity()
			slope[counter] = humidity
			if counter == step-1 :
				c = np.polyfit(np.arange(step),slope,1)
				rate = float(c[0])
				print round(rate,2)
				slope[:-1] = slope[1:]
				counter = step-2
			counter+=1

			## Numpy array creation

                	print "-----------------"
                	print "Temperature = %3.1f C" % temp
                	print "Humidity = %3.1f %%" % humidity
                	print "-----------------"
			rate = round(rate,2) * 120
			with open (filename, "a+") as f:
				f.write("%s," % tim)
                		f.write("%3.1f," % temp)
                		f.write("%3.1f," % humidity)
				f.write("%3.1f \n" % rate)

			if rate > 1.7:
				roicount+=1
			else:
				roicount=0	
			if roicount > 40:
				roialert = 1

			json_body = [
			{
				"measurement": "Environment",
				"tags": {
					"host": "raspberry"
				},
				"fields":{
					"Temperature C": temp,
					"humidity %": humidity,
					"RateofIncrease": rate,
					"alert": roialert,
					}
			}
			]
        		client = InfluxDBClient('localhost',8086,'root','root','example')
			client.switch_database('environment')
			client.write_points(json_body)

			if roicount == 0:
				roialert = 0
                	time.sleep(0.5)
	except KeyboardInterrupt:
		break
	except IOError:
		print "Check connection. Program will restart in 10 seconds"
		for i in tqdm(range(10)):
			time.sleep(1)
	#except:
	#	f.close()
	#	break


			
