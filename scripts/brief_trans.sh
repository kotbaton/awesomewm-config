#!/bin/bash

text=`zenity --entry --title="Переводчик" --text="Введите текст для перевода:"`

if [ $? -eq 1 ]
then
	exit
fi

trans -hl ru -tl ru -brief "$text" -o /tmp/trans_tmp

zenity --width=230 --height=120 --title="Перевод:" --text-info --filename="/tmp/trans_tmp"
