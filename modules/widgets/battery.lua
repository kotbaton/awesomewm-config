local awful		= require("awful")
local beautiful = require("beautiful")
local naughty	= require("naughty")
local wibox		= require("wibox")
local gears		= require("gears")
local watch		= require("awful.widget.watch")

local battery_text = wibox.widget{
	align = "center",
	widget = wibox.widget.textbox,
	text = "100%"
}

-----------{ CONTAINER }----------------
local battery = wibox.widget {
	battery_text,
	bg = "#00000000",
	fg = beautiful.colors.black,
	shape_border_width = 0,
	shape = gears.shape.rectangle,
	widget = wibox.container.background,
}

watch("acpi", 10,
    function(widget, stdout, stderr, exitreason, exitcode)
        local _, status, charge_str, time = string.match(stdout, '(.+): (%a+), (%d?%d%d)%%,? ?.*')
        local charge = tonumber(charge_str)
        battery_text:set_text(" " .. charge .. "% ")
		
		if status == 'Full' then
			battery:set_visible(false)
        else
			battery:set_visible(true)
		end

        if status == 'Charging' then
			widget.fg = beautiful.colors.black
			widget.bg = beautiful.colors.green
        else
			if charge <= 10 then
				widget.bg = beautiful.colors.darkGrey
				widget.bg = beautiful.colors.red
				if status ~= 'Charging' then
					show_battery_warning()
				end
			elseif charge > 10 and charge < 40 then
				widget.fg = beautiful.colors.black
				widget.bg = beautiful.colors.yellow
			else
				widget.bg = beautiful.colors.darkGrey
				widget.fg = beautiful.colors.white
			end
        end
    end,
    battery)

-- Popup with battery info
-- One way of creating a pop-up notification - naughty.notify
function show_battery_status()
    awful.spawn.easy_async([[bash -c 'acpi']],
        function(stdout, _, _, _)
			if notification then 
				naughty.destroy(notification)
			end
			notification = naughty.notify({
				text = stdout,
				timeout = 5,
				hover_timeout = 0.5,
			})
        end)
end

battery:connect_signal("mouse::leave", function() naughty.destroy(notification) end)
battery:buttons(gears.table.join(awful.button({ }, 1, function () show_battery_status() end)))

--[[ Show warning notification ]]
function show_battery_warning()
    naughty.notify {
        text = "Battery is dying!",
        timeout = 5,
        hover_timeout = 0.5,
        position = "top_right",
		border_width = 3,
        bg = beautiful.colors.red,
        fg = beautiful.colors.black,
		icon = "/home/sheh/.config/awesome/default/battery.png",
    }
end

return battery
