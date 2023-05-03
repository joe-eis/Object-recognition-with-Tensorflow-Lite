#!/bin/bash
source gpio  
gpio mode 7 out   
    gpio write 7 1
    sleep 2
    gpio write 7 0
    sleep 0.5
done
