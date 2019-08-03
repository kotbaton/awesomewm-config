local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local notify = require("naughty").notify

local tray = {}

local tray_widget = wibox.widget {
	widget = wibox.widget.systray(),
	visible = false,
}

tray.widget = wibox.widget {
	tray_widget,
	{
		align = "center",
		text = " < ",
		widget = wibox.widget.textbox,
	},
	layout = wibox.layout.fixed.horizontal
}

function tray.toggle()
	if tray_widget:get_visible() then
        tray_widget:set_visible(false)
    else 
        tray_widget:set_visible(true)
    end
end

tray.widget:buttons(gears.table.join(
	awful.button({ }, 1, function () 
		tray.toggle()
	end)))

return tray
