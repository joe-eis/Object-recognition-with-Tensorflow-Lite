#!/bin/bash
#
MOTION_PATH="/home/pi/python-env/motion"

echo "Lösche Bilder $MOTION_PATH/bild_tf-abgelegt/objekt*.jpg"
rm -f $MOTION_PATH/bild_tf-abgelegt/objekt*.jpg
echo "Lösche Bilder $MOTION_PATH/motion_target/pic*.jpg"
rm -f $MOTION_PATH/motion_target/pic*.jpg

echo "Leere Logdateien unter $MOTION_LOG/log"
echo " " > $MOTION_PATH/log/alarm.log
echo " " > $MOTION_PATH/log/motion.log
echo " " > $MOTION_PATH/log/objekt.log
echo " " > $MOTION_PATH/log/objekt.txt
echo " " > $MOTION_PATH/log/start.log

