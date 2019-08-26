#!/bin/bash

internal="$1"
external="$2"

internal_active=$(xrandr | grep "$internal" -A 1 | grep "*")
external_active=$(xrandr | grep "$external" -A 1 | grep "*")

external_only() {
    xrandr --output "$external" --auto --output "$internal" --off
    sleep 1
    notify-send "Screen info" "$@"
}

internal_only() {
    xrandr --output "$external" --off --output "$internal" --auto
    sleep 1
    notify-send "Screen info" "$@"
}

both_monitors() {
    xrandr --output "$internal" --auto --output "$external" --auto --left-of "$internal"
    sleep 1
    notify-send "Screen info" "Both monitors are active now."
}

if xrandr | grep "$external disconnected"; then
    internal_only "$external disconnected. Only $internal is active."

elif cat /proc/acpi/button/lid/LID0/state | grep "closed"; then
    external_only "Laptop lid closed. Only $external is active now."

elif [ "$internal_active" ] && [ "$external_active" ]; then
    internal_only "Only $internal is active now monitor."

elif [ ! "$internal_active" ] && [ "$external_active" ]; then
    both_monitors

elif [ "$internal_active" ] && [ ! "$external_active" ]; then
    external_only "Only $external is active now."

fi
