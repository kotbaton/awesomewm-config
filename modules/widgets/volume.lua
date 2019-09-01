local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local naughty   = require("naughty")
local watch     = require("awful.widget.watch")
local beautiful = require("beautiful")

local commands = require("settings").volume_commands

local volume = {}

volume.text_widget = wibox.widget {
	align = "center",
	widget = wibox.widget.textbox,
	text = " ♫..%"
}

volume.progressbar_widget = wibox.widget {
	max_value = 1,
	value = 0,
	forced_height = 36,
	forced_width = 256,
	border_width = 6,
	border_color = beautiful.colors.black,
	background_color = beautiful.colors.darkGrey,
	color = beautiful.colors.green,
	widget = wibox.widget.progressbar,
}

volume.popup_widget = awful.popup {
	widget = {
		{
			text = " Volume:",
			valign = 'center',
			halign = 'center',
			font = 'Ubuntu Mono Bold 14',
			widget = wibox.widget.textbox,
		},
		volume.progressbar_widget,
		layout = wibox.layout.fixed.horizontal,
	},
	shape = gears.shape.rect,
	opacity = 0.8,
	placement = awful.placement.top + awful.placement.no_offscreen,
    screen = awful.screen.focused(),
	ontop = true,
	border_width = 3,
	border_color = beautiful.colors.green,
	type = 'normal',
	visible = false,
}

local function update_text_widget(widget, stdout, _, _, _)
	local mute = string.match(stdout, "%[(o%D%D?)%]")
    local volume = string.match(stdout, "(%d?%d?%d)%%")
    volume = tonumber(string.format("% 3d", volume))
	if mute == "off" then
		widget:set_text(" ♫MM%")
	else
		widget:set_text(" ♫" .. volume .. "%")
	end
end

local function update_progressbar_widget(widget, stdout, _, _, _)
	local mute = string.match(stdout, "%[(o%D%D?)%]")
    local volume = string.match(stdout, "(%d?%d?%d)%%")
    volume = tonumber(string.format("% 3d", volume))
	if mute == "off" then
		widget.value = volume/100
		widget.color = beautiful.colors.grey
	else
		widget.value = volume/100
		widget.color = beautiful.colors.green
	end
end

function volume.control(cmd, value)
    value = value or 2
	if cmd == "increase" then cmd = commands.SET_VOL_CMD .. value .. '%+'
	elseif cmd == "decrease" then cmd = commands.SET_VOL_CMD .. value .. '%-'
	elseif cmd == "toggle" then cmd = commands.TOG_VOL_CMD
	end
	awful.spawn.easy_async(cmd, function(stdout, stderr, exitreason, exitcode)
			update_text_widget(volume.text_widget, stdout, stderr, exitreason, exitcode)
			update_progressbar_widget(volume.progressbar_widget, stdout, stderr, exitreason, exitcode)
	end)
    volume.popup_widget.screen = awful.screen.focused()
	volume.popup_widget.visible = true
	if volume.timer.started then
		volume.timer:again()
	else
		volume.timer:start()
	end
end

volume.timer = gears.timer {
	timeout = 1,
	callback = function()
		volume.popup_widget.visible = false
	end,
}

watch(commands.GET_VOL_CMD, 10, update_text_widget, volume.text_widget)

volume.text_widget:buttons(gears.table.join(
		awful.button({ }, 1,
			function ()
                volume.control("toggle")
			end),
		awful.button({ }, 4,
			function ()
                volume.control("increase", 2)
			end),
		awful.button({ "Shift" }, 4,
			function ()
                volume.control("increase", 10)
			end),
		awful.button({ }, 5,
			function ()
                volume.control("decrease", 2)
			end),
		awful.button({ "Shift" }, 5,
			function ()
                volume.control("decrease", 10)
			end))
)

return volume
