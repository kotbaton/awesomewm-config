local settings = {}

settings.autostart = {
    "compton",
    "nm-applet",
    "xfce4-power-manager",
    "light-locker",
    "parcellite",
    "killall perWindowLayout",
    "perWindowLayoutD",
}

settings.default_apps = {
    terminal = "kitty",
    editor = "vim",
    editor_cmd = "kitty -e vim",
}

settings.launcher = {
	app1 = 'firefox',
	app2 = 'pcmanfm',
	app3 = 'spotify',
	app4 = 'telegram-desktop',
	app5 = 'qbittorrent',
	app6 = '',
	app7 = '',
	app8 = '',
	app9 = '',
}

settings.player_commands = {
    -- Spotify commands

    GET_TRACK_CMD	    = [[sleep 0.1; dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:Metadata | grep -Eo '("(.*)")|(\b[0-9][a-zA-Z0-9.]*\b)' | grep -E "(title)|(artist)" -A 1 | tr -d '"' | grep -v : | tr -d '\n' | sed 's/--/ - /']],

    PREV_TRACK_CMD	    = 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous',
    TOGGLE_TRACK_CMD	= 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause',
    NEXT_TRACK_CMD	    = 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next',
}

return settings
