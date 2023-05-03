#!/bin/bash
sudo echo "0" > /sys/class/gpio/export
sudo echo "0" > /sys/class/gpio/export
sudo chmod 666 /sys/class/gpio/gpio0/value
sudo chmod 666 /sys/class/gpio/gpio0/direction

