#!/bin/bash

# start_tflite.bash 
# Skript wird von Motion gestartet:
# on_pictures_save /home/pi/tflite-sys/skripte/start_tflite.bash

# Achtung
# User motion in Gruppe gpio aufnehmen: usermod -aG gpio motion
# Verzeichnisse: 775 pi motion
# Test sudo -u motion ./start_tflite.bash


# copyright joe.eis aed@aed-dresden.de, 2021-01-05
# Änderung joe.eis aed@aed-dresden.de, 2021-05-12
# Namen der Dateien duerfen keine Leer- oder Sonderzeichen enthalten

# Für Aufruf von ausserhalb des Enviroments tflite-sys

# Bild-Pfad:
BILDP="/home/pi/tflite-sys/bildverarbeitung"
# Skript-Pfad
SKRP="/home/pi/tflite-sys/skripte"
# Tensorflow-lite-Pfad
TFLP="/home/pi/tflite-sys/tflite_cpu_tpu"

# Bild-Verzeichnisse
# ------------------
# $BILDP/motion_target  - Ablage Bilder, welche von Motion gemacht wurden
# $BILDP/bildablage_alt - Verarbeitete Bilder

# Zähle Bilder im Verzeichnis  $BILDP/motion_target

INB=`ls -1tr $BILDP/motion_target|wc -l`


# Nehme ältestes Bild aus Verzeichnis $BILDP/motion_target, wenn Verzeichnis nicht leer
while [ "$INB" -gt 0 ]; do

     BD=`ls -1t $BILDP/motion_target|tail -1`
      
     echo "Verzeichnis motion_target nicht leer: $INB"
     echo "Bild ist $BD"


     # Abfrage Beispiel:
     # python3 $TFLP/classify_image4cpu.py --model $TFLP/model_label/model.tflite --label $TFLP/model_label/labels.txt --input $BILDP/motion_target/$BD

     # Nehme Kamerabild $BD und lasse es durch TFLite (model_edgetpu.tflite, label.txt) erkennen und zuordnen.
     VENDOR=`lsusb |egrep "18d1|1a6e"|cut -d" " -f6|cut -d: -f1`
     # echo $VENDOR

     if [ -z "$VENDOR" ]; then 
          # echo "Kein Co-Prozessoer an USB angeschlossen"
          TIER=`python3 $TFLP/classify_image4cpu.py --model $TFLP/model_label/model.tflite --label $TFLP/model_label/labels.txt --input $BILDP/motion_target/$BD`	
          else   
        if [ "$VENDOR" = "1841" -o "$VENDOR" = "1a6e" ]; then  
          # echo "Coral-Acculator ist angesteckt" 
          TIER=`python3 $TFLP/classify_image4tpu.py --model $TFLP/model_label/model_edgetpu.tflite --label $TFLP/model_label/labels.txt --input $BILDP/motion_target/$BD`
        fi 
    fi

    VDATE=`date '+%Y-%m-%d %H:%M:%S'`
    TIERF=`echo -e $TIER |tr -s "-"|tr " " "|"|tr -s "|"| cut -d"|" -f1,28-30`
    echo -e "$VDATE:\t $TIERF" >> $SKRP/debug-Tier.log

    # A L A R M
    # Alarm-Wort
    ALWO="Taube"

#   ALAUSW=`echo $TIERF|grep $ALWO|wc -l`
    ### Setze für test auf 1: ###
    ALAUSW=1

    echo "Alarmzähler  $ALAUSW"

    if [ "$ALAUSW" -eq 1 ]; then 
        echo "$VDATE ALARM $ALWO Debug-Test" >> $SKRP/debug-alarm.log

	### Ausgang GPIO 17 für 1/2 Sekunde EIN (high) schalten:
        # echo "1" > /sys/class/gpio/gpio17/value 
        echo "Befehl: echo '1' > /sys/class/gpio/gpio17/value" 
        # GPIO17=`cat /sys/class/gpy2yio/gpio17/value`
	# echo "gpio17 ist $GPIO17"
	
	sleep 0.5
        
        echo "0" > /sys/class/gpio/gpio17/value 
        GPIO17=`cat /sys/class/gpy2yio/gpio17/value`
	echo "Befehl: echo '0' > /sys/class/gpio/gpio17/value" 

    fi


    ## echo "verschiebe $BD von $BILDP/motion_target nach $BILDP/bildablage"

    if [ ! -z "$BD" ]; then
        echo "was drinn"
	mv $BILDP/motion_target/$BD $BILDP/bildablage
    fi

    INB=`ls -1tr $BILDP/motion_target|wc -l`

done
