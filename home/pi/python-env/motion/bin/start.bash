#!/bin/bash
###  /home/pi/python-env/motion/bin/start.bash
# Joe-Eis 2022-04-03, 2023-04-12
# Start-Steuerskript
# set -x

# Definition Verzeichnisse und Variablen
export SYS_BIN="/usr/bin/"
export MOTION_AV="/home/pi/python-env/motion"
export MOTION_BIN="/home/pi/python-env/motion/bin"

export MOTION_PIC="/home/pi/python-env/motion/motion_target"
export MOTION_BV="/home/pi/python-env/motion/bildverarbeitung"
export MOTION_BA="/home/pi/python-env/motion/bildablage"

export LOG="/home/pi/log"
export TFLITE_BIN="/home/pi/python-env/tflite_cpu_tpu/bin"


sudo chown -R pi:motion /home/pi/python-env/
sudo chmod -R 775 /home/pi/python-env/

DATE=`date +%F_%H.%M.%S`
# echo "$DATE start.bash gestartet" 
echo "$DATE start.bash gestartet" >> $LOG/start.log
SEC_0=`date +%s`

# Stoppe Motion-Detektion, solange Skript läuft
# dafür muss in der /etc/motion/motion.conf webcontrol_parms auf Parameter 2 gesetzt sein
/usr/bin/lwp-request http://max:moritz2@localhost:8080/0/detection/pause  > /dev/null
#-# echo "Motion-Service gestoppt" 

LAST_PIC=`ls -1t $MOTION_PIC|grep pic|head -1`
LAST_SNAP=`ls -1t $MOTION_PIC|grep snap|grep -v lastsnap|head -1`
SEC_LAST_SNAP=`ls -1t $MOTION_PIC|grep snap|grep -v lastsnap|head -2|tail -1`

# echo "LAST_PIC:  $LAST_PIC"
# echo "LAST_SNAP: $LAST_SNAP"

# SEC_REF=`ls -l --time-style=+%s referenz |cut -d" " -f6`
SEC_REF_PIC=`ls -l --time-style=+%s $MOTION_PIC/$LAST_PIC |cut -d" " -f6`
SEC_REF_SNAP=`ls -l --time-style=+%s $MOTION_PIC/$LAST_SNAP |cut -d" " -f6`
SEC_DIFF=`expr $SEC_REF_SNAP - $SEC_REF_PIC`


# Motion macht regelmäßig Snapshots. 
# Der letzte Snapshot soll als Referenz- bzw. Differenzbild mit einem Bild, bei dem Bewegung erkannt wurde dienen, 
# um die Änderung ausschneiden zu ermöglichen. Der Snapshot soll aber min. 30 Sekunden alt sein.
# echo "Der Snapshot hat eine Differenz zur Aktion-Aufnahme von $SEC_DIFF Sekunden"

if [[ "$SEC_DIFF" -gt 30 ]]; then

    # echo "last PIC ist $LAST_PIC"
    # echo "last Snap ist $LAST_SNAP"
    
    # Nenne letzes Aktion-Bild um:
    # echo "cp $MOTION_PIC/$LAST_PIC $MOTION_PIC/after.jpg"
    # echo "cp $MOTION_PIC/$LAST_PIC $MOTION_PIC/after.jpg" >> $LOG/start.log
    cp $MOTION_PIC/$LAST_PIC $MOTION_PIC/after.jpg

    # nenne Snapshot im before um
    # echo "cp $MOTION_PIC/$LAST_SNAP $MOTION_PIC/before.jpg"
    # echo "cp $MOTION_PIC/$LAST_SNAP $MOTION_PIC/before.jpg" >> $LOG/start.log
    cp $MOTION_PIC/$LAST_SNAP $MOTION_PIC/before.jpg

    # Verkleinere Bilder für kürzere Verarbeitungszeit bei Raspi V3 # Auflösung in motion.conf geändert
    # mogrify -resize 70% $MOTION_PIC/after.jpg
    # mogrify -resize 70% $MOTION_PIC/before.jpg


    DATE2=`date +%F_%H.%M.%S`
    # echo "Rufe Python-Skript differenz_jpg.py auf"
    # echo "$DATE2: Rufe Python-Skript differenz_jpg.py auf" >> $LOG/start.log
    # Erzeuge ein rot maskiertes Bild diff.png der Unterschiede von before.jpg und after.jpg im selben Verzeichnis
    # echo "Erzeuge ein rot maskiertes Bild diff.png der Unterschiede von before.jpg und after.jpg im selben Verzeichnis" >> $LOG/start.log
    $SYS_BIN/python3  $MOTION_BIN/differenz_jpg.py

    DATE3=`date +%F_%H.%M.%S`
    # echo "Rufe trim.bash auf"
    # echo "$DATE3: Rufe trim.bash auf" >> $LOG/start.log
    # Image after.jpg wird auf die Größe von ROI.jpg getrimmt.
    $MOTION_BIN/trim.bash
    # $SYS_BIN/python3  $MOTION_BIN/trim.py

    DATE4=`date +%F_%H.%M.%S`
    # Aufruf start_tflite.bash
    # echo "Beginne Erkennung, rufe start_tflite.bash auf" 
    echo "$DATE4: Beginne Erkennung, rufe start_tflite.bash auf" >> $LOG/start.log
    $TFLITE_BIN/start_tflite.bash

    # echo "ENDE mit Bildverarbeitung" 

else

    # echo "Vergleiche mit vorletzten Snapshot"
    # echo "Test, ob Snapshot vorhanden"
        
        if [ -z "$SEC_LAST_SNAP" ]; then
       	    # echo "Variable '$SEC_LAST_SNAP' ist leer"
            # echo "ENDE ohne Bildverarbeitung, kein vorletzter Snapshot vorhanden"
            # echo "ENDE ohne Bildverarbeitung, kein vorletzter Snapshot vorhanden" >> $LOG/start.log
	    exit
        fi
	
	# echo "Wähle vorletzten Snapshot"
        # echo "last PIC ist $LAST_PIC"
        # echo "Snap ist $SEC_LAST_SNAP"

        # Nenne letzes Aktion-Bild um:
        # echo "cp $MOTION_PIC/$LAST_PIC $MOTION_PIC/after.jpg"
        # echo "cp $MOTION_PIC/$LAST_PIC $MOTION_PIC/after.jpg" >> $LOG/start.log
        cp $MOTION_PIC/$LAST_PIC $MOTION_PIC/after.jpg

        # nenne vorletzten Snapshot im before um
        # echo "cp $MOTION PIC/$SEC_LAST_SNAP $MOTION_PIC/before.jpg"
        # echo "cp $MOTION PIC/$SEC_LAST_SNAP $MOTION_PIC/before.jpg" >> $LOG/start.log
        cp $MOTION_PIC/$SEC_LAST_SNAP $MOTION_PIC/before.jpg
    
        # Verkleinere Bilder für kürzere Verarbeitungszeit bei Raspi V3 # Auflösung in motion.conf geändert
        # mogrify -resize 70% $MOTION_PIC/after.jpg
        # mogrify -resize 70% $MOTION_PIC/before.jpg

        DATE2=`date +%F_%H.%M.%S`
        # echo "$DATE2:Rufe Python-Skript differenz_jpg.py auf"
        # Erzeuge ein rot maskiertes Bild diff.png der Unterschiede von before.jpg und after.jpg im selben Verzeichnis
        # echo "Erzeuge ein rot maskiertes Bild diff.png der Unterschiede von before.jpg und after.jpg im selben Verzeichnis" >> $LOG/start.log
        # echo "Rufe Python-Skript differenz_jpg.py auf" >> $LOG/start.log
        $SYS_BIN/python3  $MOTION_BIN/differenz_jpg.py

        DATE3=`date +%F_%H.%M.%S`
        # echo "Rufe trim.bash auf"
        # echo "$DATE3: Rufe trim.bash auf" >> $LOG/start.log
        # Image after.jpg wird auf die Größe von ROI.jpg getrimmt.
        $MOTION_BIN/trim.bash

        DATE4=`date +%F_%H.%M.%S`
        # Aufruf start_tflite.bash
        # echo "Beginne Erkennung, rufe start_tflite.bash auf" 
        echo "$DATE4: Beginne Erkennung, rufe start_tflite.bash auf" >> $LOG/start.log
        $TFLITE_BIN/start_tflite.bash

        # echo "ENDE der Bildverarbeitung" 

fi


# Lösche alte Snap-Bilder, wenn diese mehrfach vorhanden
SNAP_CNT=`ls -1|grep ^snap|wc -l`

if [[ "$SNAP_CNT" -gt 3 ]]; then
  find $MOTION_PIC -type f -name "snap_*" -mmin +360 -exec rm -f {} \;
  # echo "ENDE2: Lösche noch alte Snapshots ...."
fi  

# Starte wieder die Motion-Funktion
/usr/bin/lwp-request http://max:moritz2@localhost:8080/0/detection/start  > /dev/null
#-# echo "Motion-Detektion wieder gestartet"
# echo " - - - ENDE - - -" 

DATE5=`date +%F_%H.%M.%S`
echo "$DATE5:  - - - ENDE - - -" >> $LOG/start.log 
# echo " - - - - -  - - -" >> $LOG/start.log 
# echo " " >> $LOG/start.log 

# ENDE

