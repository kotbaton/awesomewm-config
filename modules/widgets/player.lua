local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local command   = require("setting").player_commands

beautiful.init(gears.filesystem.get_configuration_dir() .. "gruvbox-theme/theme.lua")

local text = wibox.widget{
	forced_width = 220,
	align		 = "center",
	text		 = "",
    font         = "Ubuntu Mono 11",
	widget		 = wibox.widget.textbox,
}

local container = wibox.widget {
    text,
    visible = false,
    bg = beautiful.colors.green,
    fg = beautiful.colors.black,
    widget = wibox.container.background,
}

local function update_text()
    awful.spawn.easy_async_with_shell(command.GET_TRACK_CMD, function(stdout, stderr, exitreason, exitcode)
        text:set_text(stdout)
        if string.len(stdout) == 0 then
            container.visible = false
        else
            container.visible = true
        end
    end)
    return true
end

local timer = gears.timer.start_new(15, update_text)

local player = {}

player.widget = container

player.control = {}

function player.control.toggle()
    awful.spawn(command.TOGGLE_TRACK_CMD, false)
    update_text()
end

function player.control.next()
    awful.spawn(command.NEXT_TRACK_CMD, false)
    update_text()
end

function player.control.prev()
    awful.spawn(command.PREV_TRACK_CMD, false)
    update_text()
end

text:buttons(gears.table.join(
        awful.button({ }, 1, function () player.control.next() end),
        awful.button({ }, 3, function () player.control.prev() end),
        awful.button({ }, 2, function () player.control.toggle() end)
))

return player
