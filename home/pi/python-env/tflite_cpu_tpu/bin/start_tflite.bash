#!/bin/bash
# set -xv
# /home/pi/motion/tflite_cpu_tpu/bin/start_tflite.bash
# Joe-Eis 2022-04-03, 2023-04-12
# TFLite-Steuerskript

# PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# werte Foto von Motion aus. Format: Datum_Zeit.jpg
# Namen der Dateien duerfen keine Leer- oder Sonderzeichen enthalten
# User motion zur Gruppe gpio: sudo usermod -aG gpio motion
# Verzeichnisse 775 pi motion

# Aufruf durch  /home/pi/motion/bin/start.bash

# Bilder, welche von start.bash via trim.bash abgelegt werden
# Im Querformat und idealerweise in Größe des erkannten Objektes

export SYS_BIN="/home/pi/bin"
export PYT_BIN="/usr/bin"
export MOTION_BA="/home/pi/python-env/motion/bildablage"
export MOTION_VA="/home/pi/python-env/motion/bildverarbeitung"
export MOTION_BTF="/home/pi/python-env/motion/bild_tf-abgelegt"

export LOG="/home/pi/log"
export TFL_AV="/home/pi/python-env/tflite_cpu_tpu"
export TFLITE_BIN="/home/pi/python-env/tflite_cpu_tpu/bin"

# Datum in ordentlicher Form:
VDATE=`date '+%Y-%m-%d %H:%M:%S'`

# debug Aufruf Skript
# echo -e "$VDATE: Starte Skript [start_tflite.bash] " >> $LOG/start.log
# echo -e "$VDATE: Starte Skript [start_tflite.bash] "


# Zähle Bilder im Verzeichnis  motion/bildablage
INB=`ls -1t $MOTION_BA|wc -l`

# Nehme ältestes Bild aus Verzeichnis $MOTION_BA, wenn Verzeichnis nicht leer
while [ "$INB" -gt 0 ]; do

  BD=`ls -1t $MOTION_BA|tail -1`

  # echo "Start tflite.bash: Nehme ältestes Bild aus Verzeichnis $MOTION_BA, wenn Verzeichnis nicht leer: $BD" >> $LOG/start.log

  FILE=`file $MOTION_BA/$BD`
  if [[ $FILE == *"image"* ]]; then

     # Abfrage Beispiel:
     # python3 $TFL_AV/classify_image4cpu.py --model $TFL_AV/model_label/model.tflite --label $TFL_AV/model_label/labels.txt --input $MOTION_BA/$BD

     # Nehme Kamerabild $BD und lasse es durch TFLite (model_edgetpu.tflite, label.txt) erkennen und zuordnen.
     VENDOR=`lsusb |egrep "18d1|1a6e"|cut -d" " -f6|cut -d: -f1`
     # echo $VENDOR

     if [ -z "$VENDOR" ]; then 
          # echo "Kein Co-Prozessoer an USB angeschlossen"
          echo "Kein Co-Prozessoer an USB angeschlossen" >> $LOG/start.log
          OBJEKT=`$PYT_BIN/python3 $TFL_AV/bin/classify_image4cpu.py --model $TFL_AV/model_label/model.tflite --label $TFL_AV/model_label/labels.txt --input $MOTION_BA/$BD`
        else  

            if [ "$VENDOR" = "1841" -o "$VENDOR" = "1a6e" ]; then  
            # echo "Coral-Acculator ist angesteckt" 
            echo "Coral-Acculator ist angesteckt" >> $LOG/start.log
            OBJEKT=`PYT_BIN/python3 $TFL_AV/bin/classify_image4tpu.py --model $TFL_AV/model_label/model_edgetpu.tflite --label $TFL_AV/model_label/labels.txt --input $MOTION_BA/$BD`
        fi 
    fi

    OBJEKTF=`echo -e $OBJEKT |tr -s "-"|tr " "  "|"|tr -s "|"| cut -d"|" -f1,28-30`
   
    ### Test ###
    # echo "Objekt:  $OBJEKT"
    # echo "ObjektF: $OBJEKTF"

    echo -e "$VDATE: Objekt = $OBJEKT" >> $LOG/objekt.log
    # echo -e "$VDATE: $OBJEKTF" >> $LOG/Objekt.txt

    OBJEKT_SELECT=`echo $OBJEKTF |cut -d'|' -f2|cut -d: -f1`

    WERT=`echo $OBJEKTF|cut -d"|" -f3` # Erkennungswarscheinlichkeit von 0 ... 0.99999
    WERT2=`echo "$WERT*100" | bc -l` # Multipliziere der Wert mit 100 für if-Test
    WERT3=${WERT2%.*}               # Schneide Kommastelle weg, if-Test nur ganze Zahlen

    # echo "Wert3 = $WERT3"

    # A L A R M
    # Alarm-Wort
    ALWO="Taube"
    ALAUSW=`echo $OBJEKTF|grep $ALWO|wc -l`

    if [ "$ALAUSW" -eq 1 ]; then 
        # echo "$VDATE ALARM $ALWO" >> $LOG/alarm.log
        ### Alarm-Handling wurde in Skript ausgelagert, wenn Ereignis-Wahrscheinlichkeit Wert ueberschreitet:

        if [ "$WERT3" -gt 80 ];then
            echo " " >> $LOG/alarm.log
            echo "--- ALARM --- " >> $LOG/alarm.log
	    echo "Starte Skript $SYS_BIN/alarm_action.sh" >> $LOG/alarm.log
	    echo "Wahrscheinlichkeit: $WERT" >> $LOG/alarm.log
	    echo "------------------------------------------" >> $LOG/alarm.log
	    $SYS_BIN/alarm_action.bash &
        fi
    fi

    # Bezeichne Bild
    mogrify -pointsize 20 -fill red -gravity NorthWest -draw "text 8,16 'P: $WERT3 %, $OBJEKT_SELECT'" $MOTION_BA/$BD 

    ## echo "verschiebe $BD von $MOTION_BA nach $MOTION_BTF"
    if [ ! -z "$BD" ]; then
        ## echo "was drinn"
        mv $MOTION_BA/$BD $MOTION_BTF
    fi

  elif [[ $FILE == *"Matroska"* ]] || [[ $FILE == *"MP4"* ]]; then    
    mv $MOTION_BA/$BD $MOTION_AV/mp4
  fi 
  
  INB=`ls -1t $MOTION_BA|wc -l`

done

echo "Objekt ist zu $WERT3 % $OBJEKT_SELECT" >> $LOG/start.log
# echo "Ende tflite.bash" >> $LOG/start.log

# ENDE

