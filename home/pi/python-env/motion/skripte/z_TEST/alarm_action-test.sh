#!/bin/bash
# wird von start_tflite.bash gestartet

### N O T I T Z ###
### Eintrag in Boot-Startdatei /etc/rc.local
### === /home/pi/GPIO_Initialisierung.sh & : ===
### echo "0" > /sys/class/gpio/export
### echo "0" > /sys/class/gpio/export
### chmod 666 /sys/class/gpio/gpio0/value
### chmod 666 /sys/class/gpio/gpio0/direction

### === GPIO 17 aktivieren und als Ausgang definieren. 
### GPIO 17 = 11. Kontakt. Zählrichtung von 1.Reihe/links, nach 1.Reihe/rechts, nach 2. Reihe/links ...	
### echo "17" > /sys/class/gpio/export              -> /etc/rc.local
### sleep 2
### echo "out" > /sys/class/gpio/gpio17/direction   -> /etc/rc.local
### ENDE Eintrag Boot-Startdatei /etc/rc.local

### Ausgang GPIO 17 kurz EIN (high) schalten:
echo "1" > /sys/class/gpio/gpio17/value 
sleep 0.1
echo "0" > /sys/class/gpio/gpio17/value 
