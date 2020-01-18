local awful		= require("awful")
local beautiful = require("beautiful")
local naughty	= require("naughty")
local wibox		= require("wibox")
local gears		= require("gears")
local watch		= require("awful.widget.watch")

local battery = {}

local battery_text = wibox.widget{
	align = "center",
	widget = wibox.widget.textbox,
	text = "100%",
}

battery.widget = wibox.widget {
	battery_text,
	bg = "#00000000",
	fg = beautiful.colors.white,
	shape_border_width = 0,
	shape = gears.shape.rectangle,
	widget = wibox.container.background,
}

local function battery_widget_update()
    awful.spawn.easy_async([[bash -c 'acpi']], function(stdout)
        -- Prevent widget displaying if there is no battery
        if string.len(stdout) == 0 then 
			battery.widget:set_visible(false)
            return
        end

        local _, status, charge_str, time = string.match(stdout, '(.+): (%a+), (%d?%d%d)%%,? ?.*')
        local charge = tonumber(" " .. charge_str .. " ")
        battery_text:set_text(" " .. charge .. "% ")
		
		if status == 'Full' then
			battery.widget:set_visible(false)
        else
			battery.widget:set_visible(true)
		end

        if status == 'Charging' then
			battery.widget.fg = beautiful.battery_charging_fg or beautiful.colors.black
			battery.widget.bg = beautiful.battery_charging_bg or beautiful.colors.green
        else
			if charge <= 10 then
				battery.widget.fg = beautiful.battery_discharging_low_fg or beautiful.colors.black
				battery.widget.bg = beautiful.battery_discharging_low_bg or beautiful.colors.red
				if status ~= 'Charging' then
					show_battery_warning()
				end
			elseif charge > 10 and charge <= 40 then
				battery.widget.fg = beautiful.battery_discharging_medium_fg or beautiful.colors.black
				battery.widget.bg = beautiful.battery_discharging_medium_bg or beautiful.colors.yellow
			else
				battery.widget.fg = beautiful.battery_discharging_normal_fg or beautiful.colors.white
				battery.widget.bg = beautiful.battery_discharging_normal_bg or beautiful.colors.darkGrey
			end
        end
    end)
    return true
end

function battery.show_status()
    battery_widget_update()
    awful.spawn.easy_async([[bash -c 'acpi && echo "Brightness: $(xbacklight)"']],
        function(stdout, _, _, _)
			if notification then 
				naughty.destroy(notification)
			end
			notification = naughty.notify({
				text = stdout
			})
        end)
end

battery.widget:buttons(gears.table.join(awful.button({ }, 1, battery.show_status)))

-- Show warning notification
local function show_battery_warning()
    naughty.notify {
        title = "ACHTUNG!",
        text = "Battery is dying!",
        bg = beautiful.colors.red,
        fg = beautiful.colors.black,
		icon = "/home/sheh/.config/awesome/default/battery.png",
    }
end

gears.timer.start_new(15, battery_widget_update)

battery_widget_update() -- Init battery widget on startup
return battery
