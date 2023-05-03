#!/bin/bash
# motion/bin/trim.bash 

export MOTION_PIC="/home/pi/python-env/motion/motion_target"
export MOTION_AV="/home/pi/python-env/motion/"
export MOTION_BV="/home/pi/python-env/motion/bildverarbeitung"
export MOTION_BA="/home/pi/python-env/motion/bildablage"
export MOTION_CUT="/home/pi/python-env/motion/bild_cut"

# echo "trim.bash: Konvertiere $MOTION_BV/diff.png nach $MOTION_BV/diff_cut.jpg" >> $LOG/start.log
trim=$(convert $MOTION_BV/diff.png -fill black +opaque "rgb(255,0,0)" -format %@ info:)
convert $MOTION_PIC/after.jpg -crop "$trim" $MOTION_BV/diff_cut.jpg

DATE=`date +%F_%H.%M.%S`
cp $MOTION_BV/diff_cut.jpg $MOTION_CUT/pic_cut_$DATE

A=`identify  $MOTION_BV/diff_cut.jpg|cut -d" " -f3|cut -dx -f1`
B=`identify  $MOTION_BV/diff_cut.jpg|cut -d" " -f3|cut -dx -f2`
C=`echo $(($A * $B))`
D=`echo "sqrt($C)" | bc`
if [ "$D" -lt "400" ]; then
    mogrify $MOTION_BV/diff_cut.jpg -channel 'RGB' -contrast-stretch 1% -quality 92 -filter LanczosRadius -resize 400x400 
fi

BILD=$MOTION_BV/diff_cut.jpg

BILD_GEO=`identify $BILD|cut -d" " -f3`
# echo $BILD_GEO

BILD_BREIT=`identify $BILD|cut -d" " -f3|cut -dx -f1`
BILD_HOCH=`identify $BILD|cut -d" " -f3|cut -dx -f2`

# echo $BILD_BREIT
# echo $BILD_HOCH

# echo "trim.bash: Bearbeite $BILD und schreibe es als $MOTION_BA/objekt_$DATE.jpg" >> $LOG/start.log

if [[ "$BILD_HOCH" -gt "$BILD_BREIT" ]]; then
     # echo "Hochformat, trimme es auf Breitformat"
     ###     convert $BILD -crop "$BILD_BREIT"x"$BILD_BREIT"+0+0 $MOTION_BV/bild-2.jpg

     convert $BILD -background white -gravity center -extent 400x400 $MOTION_BV/bild-2.jpg

     mv $MOTION_BV/bild-2.jpg $MOTION_BA/objekt_$DATE.jpg
else
    cp $BILD $MOTION_BA/objekt_$DATE.jpg
    # echo "Breitformat"
fi

