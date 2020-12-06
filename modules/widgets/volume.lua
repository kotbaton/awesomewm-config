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
	forced_height = 50,
	forced_width = 300,
	border_width = 0,
    margins = 12,
    shape       = beautiful.volume_bar_shape or gears.shape.rectangle,
    bar_shape   = beautiful.volume_bar_shape or gears.shape.rectangle,
    background_color = beautiful.volume_bar_bg or beautiful.colors.darkGrey,
	color = beautiful.colors.green,
	widget = wibox.widget.progressbar,
}

volume.popup_widget = awful.popup {
	widget = {
		{
			text = " Volume:",
			valign = 'center',
			halign = 'center',
			widget = wibox.widget.textbox,
		},
		volume.progressbar_widget,
		layout = wibox.layout.fixed.horizontal,
	},
	shape = gears.shape.rect,
    screen = awful.screen.focused(),
	ontop = true,
	bg = beautiful.volume_popup_bg or beautiful.colors.black,
	border_width = beautiful.volume_popup_border_width or 3,
	border_color = beautiful.volume_popup_border_color or beautiful.colors.green,
	type = 'normal',
	visible = false,
}
awful.placement.top(volume.popup_widget, { margins = { top = 32 } })

local function update_text_widget(widget, stdout, _, _, _)
	local mute = string.match(stdout, "%[(o%D%D?)%]")
    local volume = string.match(stdout, "(%d?%d?%d)%%")
    volume = tonumber(string.format("% 3d", volume))
	if mute == "off" then
		widget:set_text("♫MM%")
	else
		widget:set_text("♫" .. volume .. "%")
	end
end

local function update_progressbar_widget(widget, stdout, _, _, _)
	local mute = string.match(stdout, "%[(o%D%D?)%]")
    local volume = string.match(stdout, "(%d?%d?%d)%%")
    volume = tonumber(string.format("% 3d", volume))
	if mute == "off" then
		widget.value = volume/100
		widget.color = beautiful.volume_bar_fg_muted or beautiful.colors.grey
	else
		widget.value = volume/100
		widget.color = beautiful.volume_bar_fg or beautiful.colors.green
	end
end

local active_menu = nil
local function build_menu_entry(num, name, status)
    local short_name = name:match("%.([-_%w]+)%.")
    local type = name:match("%.([-%w]+)$") -- hdmi-stereo, analog-stereo, etc.
    return {
        "[" .. string.sub(status, 1, 1) .. "] " .. type .. " " .. short_name,
        {
            {
                "Make default",
                function()
                    local command = "pactl set-default-sink " .. name
                    awful.spawn.with_shell(command)
                end
            }
        }
    }
end

local function show_pulse_sink_menu()
    if active_menu then
        active_menu:hide()
        active_menu = nil
    end

    local command = [[bash -c 'pactl list sinks short | cut -f1,2,5']]
	awful.spawn.easy_async(command, function(stdout, stderr)
        local entries = {}
        for num, name, status in string.gmatch(stdout, "(%d+)%s+([^%s]+)%s+(%w+)") do
            table.insert(entries, build_menu_entry(num, name, status))
        end
        active_menu = awful.menu({
                items = entries,
                theme = {
                    width=300,
                }
            })
        active_menu:show()
    end)
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
    awful.placement.top(volume.popup_widget, { margins = { top = 32 } })
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

watch(commands.GET_VOL_CMD, 10, update_text_widget, volume.text_widget)

volume.text_widget:buttons(gears.table.join(
		awful.button({ }, 1,
			function ()
                volume.control("toggle")
			end),
		awful.button({ }, 3, show_pulse_sink_menu),
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
