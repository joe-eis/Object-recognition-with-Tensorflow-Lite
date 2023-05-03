#!/bin/bash

LOG="/home/pi/log"

ND=`ip  -p address show|egrep 'state UP'|tr " " ":"|cut -d: -f3|head -1`
GW=`ip route|head -1 |grep default|cut -d" " -f3`
PTL=`ping -c1 $GW|grep 'packets transmitted'|tr " " ":"|cut -d: -f6|cut -d% -f1`

# echo "Network Device is $ND" # debug
# echo "Gateway is $GW"        # debug
# echo "Packets transmitting loss ist $PTL %"  # debug

if [ "$ND" == "wlan0" ]; then
	# echo "Network device is $ND"

	    if [ "$PTL" -ne 0 ]; then
		         
	        VDATE=`date '+%Y-%m-%d_%H:%M:%S'`
	        echo "$VDATE Network device is not reachable" >> $LOG/wlan0.log
				          
	        sudo ifconfig wlan0 down
		sleep 5
		sudo ifconfig wlan0 up
	    #else # debug
               # VDATE=`date '+%Y-%m-%d_%H:%M:%S'`
               # echo "$VDATE Network device is reachable" >> $LOG/wlan0.log
	   fi
fi

