local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local beautiful = require("beautiful")

local naughty = require("naughty")

beautiful.init(gears.filesystem.get_configuration_dir().. "theme/theme.lua")
----------------{ CMUS }------------------
local cmus = wibox.widget{
	forced_width = 210,
	align = "center",
	widget = wibox.widget.textbox,
	text = " Waiting for cmus "
}

-----------{ CONTAINER }----------------
local container = wibox.widget {
	cmus,
	bg = beautiful.colors.green,
	fg = beautiful.colors.black,
	forced_height = 24,
	shape_border_width = 0,
	shape = gears.shape.rectangle,
	widget = wibox.widget.background,
}

-----------{ BUTTONS }-------------------
cmus:buttons(gears.table.join(
		awful.button({ }, 1, function () awful.spawn("cmus-remote -n", false) end),
		awful.button({ }, 3, function () awful.spawn("cmus-remote -r", false) end),
		awful.button({ }, 2, function () awful.spawn("cmus-remote -u", false) end)))
--[[
function cmus_update(text)
	cmus:set_text(text)
end
--]]

function cmus_update(status, artist, song_name, cover_path)
	if notification then naughty.destroy(notification) end
	cmus:set_text(artist .. " - " .. song_name)
	notification = naughty.notify({
		title	= artist,
		text	= song_name,
		icon	= cover_path,
		width	= 300,
	})
end

return container 
