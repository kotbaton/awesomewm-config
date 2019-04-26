local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir().. "gruvbox-theme/theme.lua")

local GET_VOL_CMD = 'amixer -M get Master'
local INC_VOL_CMD = 'amixer -M set Master 3%+'
local DEC_VOL_CMD = 'amixer -M set Master 3%-'
local TOG_VOL_CMD = 'amixer -M set Master toggle'

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
	opacity = 0.90,
	placement = awful.placement.top + awful.placement.no_offscreen,
    screen = awful.screen.focused(),
	ontop = true,
	border_width = 3,
	border_color = beautiful.colors.green,
	type = 'normal',
	visible = false,
}

function volume.control(cmd)
	if cmd == "increase" then cmd = INC_VOL_CMD
	elseif cmd == "decrease" then cmd = DEC_VOL_CMD
	elseif cmd == "toggle" then cmd = TOG_VOL_CMD
	end
	awful.spawn.easy_async(cmd, function(stdout, stderr, exitreason, exitcode)
			volume.update_text_widget(volume.text_widget, stdout, stderr, exitreason, exitcode)
			volume.update_progressbar_widget(volume.progressbar_widget, stdout, stderr, exitreason, exitcode)
	end)
	volume.popup_widget.visible = true
	if volume.timer.started then 
		volume.timer:again()
	else
		volume.timer:start()
	end
end

volume.timer = gears.timer {
	timeout = 2,
	callback = function()
		volume.popup_widget.visible = false
	end,
}

function volume.update_text_widget(widget, stdout, _, _, _)
	local mute = string.match(stdout, "%[(o%D%D?)%]")
    local volume = string.match(stdout, "(%d?%d?%d)%%")
    volume = tonumber(string.format("% 3d", volume))
	if mute == "off" then
		widget:set_text(" ♫MM%")
	else
		widget:set_text(" ♫" .. volume .. "%")
	end
end

function volume.update_progressbar_widget(widget, stdout, _, _, _)
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

watch(GET_VOL_CMD, 10, volume.update_text_widget, volume.text_widget)
--watch(GET_VOL_CMD, 10, volume.update_progressbar_widget, volume.progressbar_widget)

volume.text_widget:buttons(gears.table.join(
		awful.button({ }, 1, 
			function () 
				awful.spawn(TOG_VOL_CMD, false) 
				awful.spawn.easy_async(GET_VOL_CMD, function(stdout, stderr, exitreason, exitcode)
					volume.update_text_widget(volume.text_widget, stdout, stderr, exitreason, exitcode)
				end)
			end),
		awful.button({ }, 4, 
			function () 
				awful.spawn(INC_VOL_CMD, false)
				awful.spawn.easy_async(GET_VOL_CMD, function(stdout, stderr, exitreason, exitcode)
					volume.update_text_widget(volume.text_widget, stdout, stderr, exitreason, exitcode)
				end)
			end),
		awful.button({ }, 5, 
			function () 
				awful.spawn(DEC_VOL_CMD, false)
				awful.spawn.easy_async(GET_VOL_CMD, function(stdout, stderr, exitreason, exitcode)
					volume.update_text_widget(volume.text_widget, stdout, stderr, exitreason, exitcode)
				end)
			end))
)
return volume
