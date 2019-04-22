-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local beautiful = require("beautiful")

beautiful.init(gears.filesystem.get_configuration_dir().. "gruvbox-theme/theme.lua")

local tray = {}

local tray_widget = wibox.widget {
	widget = wibox.widget.systray(),
	bg = beautiful.colors.black,
	visible = false,
}

local function mouse_near_tray()
	mcoords = mouse.coords()
	mx = mcoords.x
	my = mcoords.y
	-- TODO: rewrite this function for multiscreens
	if (mx > 1000 and my < 300) then
		return true
	else
		return false
	end
end

tray.widget = wibox.widget {
	tray_widget,
	{
		align = "center",
		text = " < ",
		widget = wibox.widget.textbox,
	},
	layout = wibox.layout.fixed.horizontal
}

tray.timer = gears.timer({
	timeout = 2,
	callback = function()
		if not mouse_near_tray() then
			tray.hide()
		end
	end
})

function tray.hide()
	tray_widget.visible = false
	tray.timer:stop()
end

function tray.show()
	tray_widget.visible = true
	tray.timer:again()
end

function tray.toggle()
	if tray_widget.visible then tray.hide() else tray.show() end
end

tray.widget:buttons(gears.table.join(
	awful.button({ }, 1, function () 
		tray.toggle()
	end)))

return tray
