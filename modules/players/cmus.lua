local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local beautiful = require("beautiful")

local naughty = require("naughty")

local player = {}

player.control = {}
function player.control.toggle()
	awful.spawn("cmus-remote -u", false)
end

function player.control.next()
	awful.spawn("cmus-remote -n", false)
end

function player.control.prev()
	awful.spawn("cmus-remote -r", false)
end

----------------{ CMUS }------------------
local cmus_text_widget = wibox.widget{
	forced_width = 210,
	align = "center",
	widget = wibox.widget.textbox,
	text = " Waiting for cmus "
}

-----------{ WIDGET }----------------
player.widget = wibox.widget {
	cmus_text_widget,
	bg = beautiful.colors.green,
	fg = beautiful.colors.black,
	forced_height = 24,
	shape_border_width = 0,
	shape = gears.shape.rectangle,
	widget = wibox.widget.background,
}

-----------{ BUTTONS }-------------------
cmus_text_widget:buttons(gears.table.join(
		awful.button({ }, 1, function () player.control.next() end),
		awful.button({ }, 3, function () player.control.prev() end),
		awful.button({ }, 2, function () player.control.toggle() end)))

function cmus_update(status, artist, song_name, cover_path)
	if notification then naughty.destroy(notification) end
	cmus_text_widget:set_text(artist .. " - " .. song_name)
	notification = naughty.notify({
		title	= artist,
		text	= song_name,
		icon	= cover_path,
		width	= 400,
	})
end

return player 

