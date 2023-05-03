sudo -u motion  echo "1" > /sys/class/gpio/gpio17/value  && sleep 0.5 && sudo -u motion  echo "0" > /sys/class/gpio/gpio17/value 
