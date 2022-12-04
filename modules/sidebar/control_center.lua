local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local naughty   = require("naughty")
local beautiful = require("beautiful") 
local dpi       = require("beautiful.xresources").apply_dpi

local function run_and_notify_error(command)
    awful.spawn.easy_async(command, function(stdout, stderr, reason, exit_code)
        if stderr ~= nil and stderr ~= '' then
            naughty.notification{
                title = '<b>Error!</b>',
                message = stderr,
                timeout = 10
            }
        end
    end)
end

--[[
Params:
- Image
- Action
--]]
local function create_button(args)
    local button = awful.widget.button({
        image = args.image,
        buttons = {
            awful.button({}, 1, nil, args.action)
        },
        forced_height   = beautiful.monitor_contorl_icon_size or dpi(64),
        forced_width    = beautiful.monitor_contorl_icon_size or dpi(64),
        resize          = true,
        upscale         = true,
        scaling_quality = 'nearest',
    })

    return wibox.widget{
        button,
        bg = beautiful.colors.darkGrey,
        forced_height   = beautiful.monitor_contorl_icon_size or dpi(64),
        forced_width    = beautiful.monitor_contorl_icon_size or dpi(64),
        border_width    = dpi(2),
        border_color    = beautiful.colors.darkGrey .. 'AA',
        shape           = gears.shape.squircle,
        widget          = wibox.container.background
    }
end

local layout_widget = wibox.widget {
    create_button{
        image  = beautiful.control.monitor_reset,
        action = function()
            command = [[bash -c "
            xrandr --output HDMI2 --off --output eDP1 --mode 1920x1080 --rotate normal;
            xinput --map-to-output 'Raydium Corporation Raydium Touch System' eDP1
            "]]
            run_and_notify_error(command)
        end
    },
    create_button{
        image  = beautiful.control.monitor_rotated,
        action = function()
            command = [[bash -c "
            xrandr --output eDP1 --mode 1920x1080 --rotate right;
            xinput --map-to-output 'Raydium Corporation Raydium Touch System' eDP1
            "]]
            run_and_notify_error(command)
        end
    },
    create_button{
        image  = beautiful.control.monitor_external_rotated,
        action = function()
            command = [[bash -c "
            xrandr --output HDMI2 --mode 1920x1080 --scale 1.25x1.25 --output eDP1 --mode 1920x1080 --pos 2400x0 --rotate right;
            xinput --map-to-output 'Raydium Corporation Raydium Touch System' eDP1
            "]]
            run_and_notify_error(command)
        end
    },
    create_button{
        image  = beautiful.control.monitor_external_duplicated,
        action = function()
            command = [[bash -c "
            xrandr --output HDMI2 --mode 1920x1080 --scale 1.0x1.0 --rate 60.00 --same-as eDP1 --output eDP1 --mode 1920x1080 --rotate normal;
            xinput --map-to-output 'Raydium Corporation Raydium Touch System' eDP1
            "]]
            run_and_notify_error(command)
        end
    },
    
    -- TODO: External normal
    -- TODO: Start kitty + port forwarding + synergy

    homogeneous     = true,
    spacing         = dpi(8),
    forced_num_cols = 4,
    forced_num_rows = 3,
    min_cols_size   = dpi(48),
    min_rows_size   = dpi(48),
    expand          = false,
    --forced_width    = dpi(256),
    layout          = wibox.layout.grid
}

local wrapper_widget = wibox.widget {
    layout_widget,
    halign = 'center',
    valign = 'center',
    widget  = wibox.container.place
}

return {
    widget = wrapper_widget
}
