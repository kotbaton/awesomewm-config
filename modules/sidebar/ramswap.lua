local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful") 
local dpi       = require("beautiful.xresources").apply_dpi

local helpers   = require("modules.sidebar.helpers")

-- RAM bar widget
local ram_bar = wibox.widget {
    max_value        = 1,
    value            = 0,
    color            = beautiful.si_ram_bar_fg or beautiful.colors.green .. '99',
    background_color = beautiful.si_ram_bar_bg or beautiful.colors.black,
    forced_height    = dpi(30),
    forced_width     = dpi(200),
    shape            = beautiful.si_bar_shape or gears.rectangle,
    bar_shape        = beautiful.si_bar_shape or gears.rectangle,
    widget           = wibox.widget.progressbar,
}

-- swap bar widget
local swap_bar = wibox.widget {
    max_value        = 1,
    value            = 0,
    color            = beautiful.si_swp_bar_fg or beautiful.colors.green .. '99',
    background_color = beautiful.si_swp_bar_bg or beautiful.colors.black,
    forced_height    = dpi(30),
    forced_width     = dpi(200),
    shape            = beautiful.si_bar_shape or gears.rectangle,
    bar_shape        = beautiful.si_bar_shape or gears.rectangle,
    widget           = wibox.widget.progressbar,
}

local function update()
    local command = "free -m"
    awful.spawn.easy_async(command, function(stdout)
            local total, used, free, shared, buff, available, total_swap, used_swap, _ =
                stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
            ram_bar:set_value((used+shared)/total)
            swap_bar:set_value(used_swap/total_swap)
    end)
end

return {
    widget = {
        ram  = helpers.add_label("", ram_bar),
        swap = helpers.add_label("", swap_bar),
    },
    update = update,
}
