#!/bin/bash
text=`xclip -o`

if [ $? -eq 1 ]
then
	exit
fi

trans -hl ru -tl ru -brief "$text" -o /tmp/brief_trans.out

zenity\
    --width=400\
    --height=720\
    --title="Translation"\
    --text-info --filename="/tmp/brief_trans.out"

rm /tmp/brief_trans.out
