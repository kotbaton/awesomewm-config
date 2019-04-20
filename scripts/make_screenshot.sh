#!/bin/bash
screenshots_dir=$HOME/Pictures/Screenshots
time=`date +%Y-%m-%d-%H-%M-%S`
image_path=$screenshots_dir"/"$time".png"
options=""
edit=0

case $1 in 
	"-s")
		options+="-s"
		;;
	"-e")
		edit=1
		;;
	"-es"|"-se")
		options+="-s"
		edit=1
		;;
esac

scrot $options $image_path

if [ -f $image_path ]
then
	notify-send -t 3000 "Screenshot saved!" -i $image_path
else
	notify-send -t 3000 "Something goes wrong!"
fi

if [ $edit -eq 1 ]
then
	gimp $image_path 2> /dev/null &
fi
