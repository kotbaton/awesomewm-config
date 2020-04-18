local settings = {}

-- Put there only apps which you need to start with awesome
-- If you looking for way to start applications with X you
-- can use ~/.xprofile file.
-- Read more: https://wiki.archlinux.org/index.php/Xprofile
settings.autostart = {

}

-- Set default apps:
-- This commands will be used in main menu.
-- If you want to change smth else in main menu
-- you need to edit modules/menus/mainmenu.lua file.
settings.default_apps = {
    terminal = "",
    editor = "",
    editor_cmd = "",
    browser = "",
}

-- Set applications which you want to run with Super+Alt+number.
settings.launcher = {
    -- 'appliction1',
    -- 'appliction2',
    -- ...
}

-- Set yout API key and city id for weather widget.
-- More info: https://openweathermap.org/
settings.user = {
    api_key     = "",
    city_id     = "",
}

-- Put here monitor names from xrandr command.
-- It will be used by monitor_toggle script.
settings.monitors = {
    internal = "",
    external = "",
}

-- Put here command which will lock your computer.
settings.lock_command = "light-locker-command --lock"

-- Put here commands for volume control.
-- SET_VOL_CMD must be with space at the end,
-- because it will be concatenated with number.
settings.volume_commands = {
    GET_VOL_CMD = "amixer -D pulse sget Master",
    SET_VOL_CMD = "amixer -D pulse sset Master ",
    TOG_VOL_CMD = "amixer -D pulse sset Master toggle",
}

-- Change this command, if you use another player.
-- This commands are for spotify.
settings.player_commands = {
    GET_TRACK_CMD		= [[sleep 0.1; dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:Metadata | grep -Eo '("(.*)")|(\b[0-9][a-zA-Z0-9.]*\b)' | grep -E "(title)|(artist)" -A 1 | tr -d '"' | grep -v : | tr -d '\n' | sed 's/--/ - /']],

    PREV_TRACK_CMD		= "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous",
    TOGGLE_TRACK_CMD	= "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause",
    NEXT_TRACK_CMD		= "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next",
}

return settings
