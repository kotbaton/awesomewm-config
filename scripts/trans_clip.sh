#!/bin/bash
text=`xclip -o`

if [ $? -eq 1 ]
then
	exit
fi

trans -hl ru -tl ru -brief "$text" -o /tmp/trans_tmp

zenity --width=500 --height=350 --title="Перевод:" --text-info --filename="/tmp/trans_tmp"
