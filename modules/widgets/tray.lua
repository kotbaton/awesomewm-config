local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local notify = require("naughty").notify

local tray = {}

-- For checking if cursor is around tray
local scr_g = screen.primary.geometry
-- Coordinates of upper right corner (where the widget should be)
local corner = {
    x = scr_g.x + scr_g.width,
    y = scr_g.y
}
local max_dist = (scr_g.width^2 + scr_g.height^2) ^ 0.5 / 5

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
	callback = function()
        -- Get coordinates of the cursor
        -- and hide tray if mouse is far from it
        local mg = mouse.coords()
        local dist = ((mg.x - corner.x)^2 + (mg.y - corner.y)^2)^0.5
        if dist > max_dist then
            tray_widget:set_visible(false)
            tray.timer:stop()
        end
	end
})

tray.widget:buttons(gears.table.join(
	awful.button({ }, 1, function () 
		tray.toggle()
	end)))

return tray
