#!/bin/bash
screenshots_dir=$HOME/Pictures/Screenshots
time=`date +%Y-%m-%d-%H-%M-%S`
image_path=$screenshots_dir"/"$time".png"
options=""

edit_action() {
	gimp $image_path 2> /dev/null &
}

delete_action() {
    rm $image_path
}


if [ ! -d $screenshots_dir ]; then
    mkdir -p $screenshots_dir
    notify-send -t 3000 "Screenshots dir has been created: $screenshots_dir"
fi

case $1 in
	"-s")
		options+="-s"
		;;
esac

# Actually take screenshot
scrot $options $image_path

if [ -f $image_path ]
then
    action=$(dunstify --timeout=5000\
             --action="delete,Delete"\
             --action="dismiss,Dismiss"\
             --action="edit,Edit"\
             --icon="$image_path"\
             "Scrot"\
             "Screenshot saved!")

    case $action in
        "delete")
            delete_action
            ;;
        "edit")
            edit_action
            ;;
        *)
            ;;
    esac
else
	dunstify --timeout 3000 "Scrot" "Something goes wrong!"
fi
