local settings = {}

-- Put there only apps which you need to start with awesome
settings.autostart = {

}

-- Set default apps
settings.default_apps = {
    terminal = "",
    editor = "",
    editor_cmd = "",
}

-- Set applikations which you want to run with Super+Alt+number
settings.launcher = {
	app1 = '',
	app2 = '',
	app3 = '',
	app4 = '',
	app5 = '',
	app6 = '',
	app7 = '',
	app8 = '',
	app9 = '',
}

-- Set yout API key and city id for weather widget
-- More info: https://openweathermap.org/
settings.user = {
    api_key     = "",
    city_id     = "",
}

settings.monitors = {
    -- For laptops
    -- Put here monitor names from xrandr command
    internal = "",
    external = "",
}

-- Change this command, if you use another player
settings.player_commands = {
    GET_TRACK_CMD		= [[sleep 0.1; dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:Metadata | grep -Eo '("(.*)")|(\b[0-9][a-zA-Z0-9.]*\b)' | grep -E "(title)|(artist)" -A 1 | tr -d '"' | grep -v : | tr -d '\n' | sed 's/--/ - /']],

    PREV_TRACK_CMD		= 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous',
    TOGGLE_TRACK_CMD	= 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause',
    NEXT_TRACK_CMD		= 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next',
}

return settings
