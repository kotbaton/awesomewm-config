local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local command   = require("settings").player_commands

local text = wibox.widget{
	forced_width = beautiful.player_widget_width,
	align		 = "center",
    valign       = "center",
	text		 = "...",
    font         = beautiful.player_widget_font,
	widget		 = wibox.widget.textbox,
}

local container = wibox.widget {
        text,
        bg = {
            type  = 'linear',
            from  = { 0, 0 },
            to    = { 0, 24 },
            stops = {
                { 0.1, beautiful.player_widget_bg },
                { 0.1, beautiful.player_widget_bg .. '22' }
            }
        },
        fg = beautiful.player_widget_fg or beautiful.colors.black,
        widget = wibox.container.background,
}

local function update_text()
    awful.spawn.easy_async_with_shell(command.GET_TRACK_CMD, function(stdout, stderr, exitreason, exitcode)
        text:set_text(stdout)
        if string.len(stdout) == 0 then
            container:set_visible(false)
        else
            container:set_visible(true)
        end
    end)
    return true
end

local timer = gears.timer.start_new(5, update_text)

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

container:buttons(gears.table.join(
        awful.button({ }, 1, function () player.control.next() end),
        awful.button({ }, 3, function () player.control.prev() end),
        awful.button({ }, 2, function () player.control.toggle() end)
))

update_text() -- Init player widget on startup
return player
