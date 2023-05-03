#!/bin/bash
# wird von start_tflite.bash gestartet

VDATE=`date '+%Y-%m-%d %H:%M:%S'`
LOG="/home/pi/log"
ID=`id`
PFAD=`echo $PATH`

echo "$VDATE: alarm_action wird ausgefuehrt" >>$LOG/action-wiringPi.log
echo "*" >>$LOG/action-wiringPi.log

### GPIO_Initialisierung writingPi
gpio -g mode 17 out

### Ausgang GPIO 17 für einige Sekunden EIN (high) schalten:
# an
gpio -g write 17 1
sleep 12
# aus
gpio -g write 17 0
# 

## Mehrfach:
# sleep 0.5
## an
# gpio -g write 17 1
# sleep 0.5
## aus
# gpio -g write 17 0
# 
# sleep 0.5
## an
# gpio -g write 17 1
sleep 1
## aus
# gpio -g write 17 0
# 
# gpio -g read 17
