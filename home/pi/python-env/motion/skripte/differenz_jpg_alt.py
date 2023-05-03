#!/usr/bin/env python3 
# motion/bin/differenz_jpg.py, Aufruf via Wrapper von start.bash
# Bildunterschiede rot maskieren 

import cv2
import cv2 as cv
import os

# load images
# image1 = cv2.imread('/home/pi/python-env/motion/motion_target/before.jpg')
# image2 = cv2.imread('/home/pi/python-env/motion/motion_target/after.jpg')

MOTION_PIC = "/home/pi/python-env/motion/motion_target"
BEFORE_PIC = "before.jpg"
AFTER_PIC = "after.jpg"

MOTION_BEFORE_PIC = os.path.join(MOTION_PIC, BEFORE_PIC)
MOTION_AFTER_PIC = os.path.join(MOTION_PIC, AFTER_PIC)

image1 = cv2.imread(MOTION_BEFORE_PIC)
image2 = cv2.imread(MOTION_AFTER_PIC)

####################################################################
# blur 
image1b = cv2.boxFilter(image1,-1,(5,5), normalize = True)
image2b = cv2.boxFilter(image2,-1,(5,5), normalize = True)

# denoise
image1a = cv.fastNlMeansDenoisingColored(image1b,None,20,20,7,21)
image2a = cv.fastNlMeansDenoisingColored(image2b,None,20,20,7,21)
####################################################################

# compute difference
difference = cv2.subtract(image1a, image2a)

# color the mask red
Conv_hsv_Gray = cv2.cvtColor(difference, cv2.COLOR_BGR2GRAY)
ret, mask = cv2.threshold(Conv_hsv_Gray, 0, 255,cv2.THRESH_BINARY_INV |cv2.THRESH_OTSU)
difference[mask != 255] = [0, 0, 255]

# add the red mask to the images to make the differences obvious
image1a[mask != 255] = [0, 0, 255]
image2a[mask != 255] = [0, 0, 255]

# cv2.imwrite('/home/pi/python-env/motion/bildverarbeitung/diff.png', difference)
MOTION_BV = "/home/pi/python-env/motion/bildverarbeitung"
BILD_NAME = "diff.png"
PFAD_BILD = os.path.join(MOTION_BV, BILD_NAME)

cv2.imwrite(PFAD_BILD, difference)

