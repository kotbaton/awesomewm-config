local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful") 
local dpi       = require("beautiful.xresources").apply_dpi

-- Import widgets
local weather  = require("modules.sidebar.weather")
local calendar = require("modules.sidebar.calendar")
local ramswap  = require("modules.sidebar.ramswap")
local cpu      = require("modules.sidebar.cpu")
local sensors  = require("modules.sidebar.sensors")

-- Import helpers
local helpers  = require("modules.sidebar.helpers")

local google_tasks = require("google_tasks")

-- Create popup widget and set layout
local popup = wibox({
        y               = dpi(24),
        ontop           = true,
        opacity         = 1.0,
        bg              = beautiful.si_outer_bg or beautiful.colors.bg_normal,
        shape           = beautiful.si_outer_border_shape or gears.shape.rectangle,
        border_color    = beautiful.si_outer_border_color or beautiful.colors.green,
        border_width    = beautiful.si_outer_border_width or dpi(2),
        width           = dpi(300),
        type            = "dock",
        visible         = false,
    })

-- Decorator arguments: decorator(w, vmargin, hmargin, fg)
popup:setup{
    {
        helpers.decorator(weather.widget, dpi(10)),
        layout = wibox.layout.fixed.vertical,
    },
    {
        helpers.decorator(cpu.widget),
        helpers.decorator(ramswap.widget.ram, nil, nil, beautiful.colors.green),
        helpers.decorator(ramswap.widget.swap, nil, nil, beautiful.colors.yellow),
        helpers.decorator(sensors.widget),

        helpers.decorator(google_tasks.widget),

        spacing = dpi(8),
        layout = wibox.layout.fixed.vertical,
    },
    {
        helpers.decorator(calendar.widget, nil, dpi(35)),
        layout = wibox.layout.fixed.vertical,
    },
    layout = wibox.layout.align.vertical,
}

local function timer_callback()
    ramswap.update()
    cpu.update()
    sensors.update()
end

-- Timer with update callback
local timer = gears.timer({
    timeout = 1,
    callback = timer_callback
})

local sidebar = {}
function sidebar.toggle()
    if not timer.started then
        timer_callback()

        -- Update this only when open sidebar
        weather.update()
        calendar.update()

        local fscreen = awful.screen.focused()
        local geo = fscreen.geometry
        popup.screen = fscreen
        popup.height = geo.height - dpi(24)
        popup.y = geo.y + dpi(24)
        popup.x = geo.x + geo.width - dpi(300)
        popup.visible = true
        timer:start()
    else
        timer:stop()
        popup.visible = false
        collectgarbage('collect')
    end
end

popup:buttons(gears.table.join(awful.button({}, 1, function()
    sidebar.toggle()
end)))

return sidebar
