#!/bin/bash
# start_loop.bash

# motion legt eine Bilddatei mit Bezeichnung detect_DATUM_lfd.Nr.jpg in motion_target ab.
# start_loop wird von Motion aufgerufen, zählt die detct-Dateinen und nimmt die älteste detct-Datei, 
# nennt diese in pic_DATUM_lfd.Nr.jpg um und startet das Skript start.bash.
#
# 

# Definition Verzeichnisse und Variablen
export MOTION_PIC="/home/pi/python-env/motion/motion_target"
export MOTION_BIN="/home/pi/python-env/motion/bin"

PZAN_LOOP=`ps ax|grep -v grep|grep start_loop.bash|wc -l`

if [ "$PZAN_LOOP" -gt 3 ]; then
    echo "nur einmal vs $PZAN_LOOP"
    exit
else
	echo "$PZAN_LOOP, passt, weiter ..."
fi       



PZ_START=`ps ax|grep -v grep|grep start.bash`
TF_START=`ps ax|grep -v grep|grep start_tflite.bash`
CL_IMAGE=`ps ax|grep -v grep|grep classify_image`

while [ -n "$PZ_START" -o -n "$TF_START" -o -n "$CL_IMAGE" ]
do 
    echo "Prozess start.bash bereits gestartet"
    sleep 6
    PZ_START=`ps ax|grep -v grep|grep start.bash`
    TF_START=`ps ax|grep -v grep|grep start_tflite.bash`
    CL_IMAGE=`ps ax|grep -v grep|grep classify_image`

done

# Motion Bewegungserkennung generiert Bilder im Format detect_DATUM_ZEIT
# Anzahl motion-detect-Bilder und ältestes motion-detect-Bild:

ANZ_DET=`ls -1 $MOTION_PIC |grep detect| wc -l`

while [ "$ANZ_DET" -ge "1" ]

do
    # Álteste Motion-detect-Bilddatei wird erkannt und zu pic umbenannt
    LETZT_DET=`ls -1 $MOTION_PIC |grep detect|head -1`

    echo "Anzahl detect_: $ANZ_DET"
    echo "Datei zum umbenennen: $LETZT_DET"

    UMB2PIC="${LETZT_DET/detect/pic}"
    echo "$UMB2PIC"
    echo "Zu pic umbenannte Bilddatei: $UMB2PIC"

    mv $MOTION_PIC/$LETZT_DET $MOTION_PIC/$UMB2PIC

    $MOTION_BIN/start.bash    

    LETZT_PIC=`ls -1 $MOTION_PIC|grep pic|head -1`
    UMB2OLD="${LETZT_PIC/pic/old}"
    mv $MOTION_PIC/$LETZT_PIC $MOTION_PIC/$UMB2OLD

    ANZ_DET=`ls -1 $MOTION_PIC |grep detect| wc -l`
done




