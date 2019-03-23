local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir().. "theme_without_borders/theme.lua")

local GET_CMD = "python3 " .. gears.filesystem.get_configuration_dir() .. "scripts/spotify-status.py"
local NEXT_CMD = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"
local PREV_CMD = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous"
local TOGGLE_CMD = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"

local spotify = {}

spotify.text = wibox.widget{
	forced_width = 210,
	align = "center",
	widget = wibox.widget.textbox,
	text = ""
}

spotify.widget = wibox.widget {
	spotify.text,
	bg = beautiful.colors.green,
	fg = beautiful.colors.black,
	forced_height = 24,
	shape_border_width = 0,
	shape = gears.shape.rectangle,
	widget = wibox.widget.background,
}

-----------{ BUTTONS }-------------------
spotify.widget:buttons(gears.table.join(
		awful.button({ }, 1, function () awful.spawn(NEXT_CMD, false) end),
		awful.button({ }, 3, function () awful.spawn(PREV_CMD, false) end),
		awful.button({ }, 2, function () awful.spawn(TOGGLE_CMD, false) end)))

function spotify.update_text(widget, stdout, _, _, _)
	widget:set_text(stdout)
end

watch(GET_CMD, 10, spotify.update_text, spotify.text_widget)

return spotify
