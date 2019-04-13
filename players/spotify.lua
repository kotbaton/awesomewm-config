local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local DBUS_PREFIX		= 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 '

local PREV_TRACK_CMD	= DBUS_PREFIX .. "org.mpris.MediaPlayer2.Player.Previous"
local TOGGLE_TRACK_CMD	= DBUS_PREFIX .. "org.mpris.MediaPlayer2.Player.PlayPause"
local NEXT_TRACK_CMD	= DBUS_PREFIX .. "org.mpris.MediaPlayer2.Player.Next"

local GET_TRACK_CMD	= [[sleep 0.1; dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:Metadata | grep -Eo '("(.*)")|(\b[0-9][a-zA-Z0-9.]*\b)' | grep -E "(title)|(artist)" -A 1 | tr -d '"' | grep -v : | tr -d '\n' | sed 's/--/ - /']]

local text = wibox.widget{
	forced_width = 210,
	align		 = "center",
	text		 = "",
	widget		 = wibox.widget.textbox,
}

local function update_text()
	awful.spawn.easy_async_with_shell(GET_TRACK_CMD, function(stdout, stderr, exitreason, exitcode)
		text:set_text(stdout)
	end)
end

local player = {}

player.widget = awful.widget.watch(
		'bash -c "~/.scripts/sp current-track"',
		15,
		function(widget, stdout, stderr)
			widget:set_text(stdout)
		end,
		text
)

player.control = {}

function player.control.toggle()
	awful.spawn(TOGGLE_TRACK_CMD, false)
	update_text()
end

function player.control.next()
	awful.spawn(NEXT_TRACK_CMD, false)
	update_text()
end

function player.control.prev()
	awful.spawn(PREV_TRACK_CMD, false)
	update_text()
end

text:buttons(gears.table.join(
		awful.button({ }, 1, function () player.control.next() end),
		awful.button({ }, 3, function () player.control.prev() end),
		awful.button({ }, 2, function () player.control.toggle() end)))

return player
