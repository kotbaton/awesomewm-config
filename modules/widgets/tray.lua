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
        tray.timer:stop()
    else 
        tray_widget:set_visible(true)
        tray.timer:start()
    end
end

tray.timer = gears.timer({
	timeout = 5,
    single_shot = true,
	callback = function()
        tray_widget:set_visible(false)
	end
})

tray.widget:buttons(gears.table.join(
	awful.button({ }, 1, function () 
		tray.toggle()
	end)))

return tray
