local settings = {}

settings.autostart = {
    "compton",
    "nm-applet",
    "xfce4-power-manager",
    "light-locker",
    "parcellite",
    "perWindowLayoutD",
}

settings.default_apps = {
    terminal = "kitty",
    editor = "vim",
    editor_cmd = "kitty -e vim",
}

settings.launcher = {
	app1 = 'google-chrome-stable',
	app2 = 'pcmanfm',
	app3 = 'spotify',
	app4 = 'telegram-desktop',
	app5 = 'qbittorrent',
	app6 = '',
	app7 = '',
	app8 = '',
	app9 = '',
}

return settings
