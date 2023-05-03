#!/usr/bin/python3
import RPi.GPIO as GPIO
import time
 
GPIO.setmode(GPIO.BCM)   #Art der Pin-Nummerierung
GPIO.setup(17, GPIO.OUT)   #Pin7 als Output einstellen
GPIO.output (17, GPIO.HIGH)   #Pin7 auf HIGH stellen, d.h. Spannung von 3.3V einschalten
time.sleep(0.5)   #Pause von 5 Sekungen
GPIO.output (17, GPIO.LOW)   #Pin 7 auf LOW, d.h. Spannung ausschalten
GPIO.cleanup()   #Alle GPIO Einstellungen zurücksetzen

