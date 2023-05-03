# Object-recognition-with-Tensorflow-Lite
Distinguishing animals and humansby Google teachable machine trained Tensorflow Lite files on a raspberry PI V3 and a USB webcam. 

https://youtu.be/l36XWpxnNPU


Prerequisite
-------------
Installed Raspberry Pi image with the program "motion", Python 3.7, OpenCV-Python and the TensorflowLite runtime


How it works
------------

program "motion" takes cyclic snapshots, takes pictures when motion is detected and starts the script /Scan
the script /home/pi/python-env/motion/bin/start.bash.

/home/pi/python-env/motion/bin/start.bash looks for the last snapshot and motion detection shots and renames them to before.jpg and after.jpg.


/home/pi/python-env/motion/bin/start.bash starts /home/pi/python-env/motion/bin/fdifference_jpg.py

        /home/pi/python-env/motion/bin/fdifference_jpg.py:
        compares the before.jpg and after.jpg and creates a black image
        diff.png with the difference colored in red.


/home/pi/python-env/motion/bin/start.bash starts /home/pi/python-env/motion/bin/trim.bash

       /home/pi/python-env/motion/bin/trim.bash:
       trims image by colored section and saves it as
       as /home/pi/python-env/motion/image_cut/pic_cut_DATUM.jpg.

       /home/pi/python-env/motion/image_processing/ temporary_file for square or landscape formatted created object_DATUM.fdifferenz_jpg


/home/pi/python-env/motion/bin/start.bash starts /home/pi/python-env/tflite_cpu_tpu/bin/start_tflite.bash

      /home/pi/python-env/tflite_cpu_tpu/bin/start_tflite.bash:
      Take oldest image from directory /home/pi/python-env/motion/image-storage and send it through classify_image.py, which determines the image content.
      Values content (class/object) and start alarm_action.sh if necessary.
      Label image with object and probability and move it to /home/pi/python-env/image_tf-filed/object_DATUM.jpg.


=======================================

Objekterkennung mit Tensorflow Lite

Unterscheidung von Tieren und Menschendurch von Google teachable machine trainierte Tensorflow Lite Dateien auf einem raspberry PI V3 und einer USB-Webcam.



Voraussetzung
-------------
Installiertes Raspberry Pi Image mit dem Programm "motion", Python 3.7, OpenCV-Python und der TensorflowLite-Runtime


Arbeitsweise
------------

Programm "motion" macht einmal zyklisch Schnappschüsse, zum anderen Aufnahmen bei Bewegungserkennung und startet
anschliessend das Skript /home/pi/python-env/motion/bin/start.bash.


/home/pi/python-env/motion/bin/start.bash sucht die letzen Snapschuss- und Bewegungs-Aufnahmen und nennt diese in before.jpg und after.jpg um.


/home/pi/python-env/motion/bin/start.bash startet /home/pi/python-env/motion/bin/fdifferenz_jpg.py


        /home/pi/python-env/motion/bin/fdifferenz_jpg.py:
        vergleicht die before.jpg und after.jpg und erstellt ein schwarzes Bild
        diff.png mit rot eingefärbten Unterschied.



/home/pi/python-env/motion/bin/start.bash startet /home/pi/python-env/motion/bin/trim.bash


       /home/pi/python-env/motion/bin/trim.bash:
       schneidet Bild um eingefärbten Ausschnitt und speichert dieses
       als  /home/pi/python-env/motion/bild_cut/pic_cut_DATUM.jpg.


       /home/pi/python-env/motion/bildverarbeitung/ temporäre Ablage für quadratisch- oder querformatigen erstellte objekt_DATUM.fdifferenz_jpg



/home/pi/python-env/motion/bin/start.bash startet /home/pi/python-env/tflite_cpu_tpu/bin/start_tflite.bash


      /home/pi/python-env/tflite_cpu_tpu/bin/start_tflite.bash:
      Nehme ältestes Bild aus Verzeichnis /home/pi/python-env/motion/bildablage und schicke dieses durch classify_image.py, welches den Bildinhalt feststellt.
      Werte Inhalt (Klasse/Objekt) aus und start ggf. alarm_action.sh.
      Beschrifte Bild mit Objekt und Wahrscheinlichkeitund verschiebe es nach /home/pi/python-env/bild_tf-abgelegt/objekt_DATUM.jpg.
