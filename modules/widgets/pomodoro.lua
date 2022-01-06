local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local naughty   = require("naughty")
local beautiful = require("beautiful")

local pomodoro = {}

local function pomodoro_notify(message)
    naughty.notify({
        title   = "Pomodoro Timer",
        message = "<b>" .. message .. "</b>",
        timeout = 10,
        bg      = beautiful.colors.red,
        image   = beautiful.pomodoro_icon,
    })
end

-- State and start time in the same time
local STATE = {
    WORK  = 25 * 60,
    BREAK = 5 * 60
}

local text_widget = wibox.widget {
    forced_width = beautiful.pomodoro_forced_width,
	align        = "center",
	text         = " 00:00 ",
	widget       = wibox.widget.textbox,
}

pomodoro.widget = wibox.widget {
    text_widget,
    bg      = beautiful.pomodoro_work_widget_bg or beautiful.colors.white,
    fg      = beautiful.pomodoro_work_widget_fg or beautiful.colors.black,
    visible = false,
    widget  = wibox.container.background
}

local state = STATE.WORK
local time_to_end = STATE.WORK + 1

-- Placeholder for function
function pomodoro.update_widget()
    time_to_end = time_to_end - 1

    new_text = string.format(" %02.0f:%02.0f ", math.floor(time_to_end / 60), time_to_end % 60)
    text_widget:set_text(new_text)

    if time_to_end <= 0 then
        pomodoro.change_state()
    end
end

pomodoro.timer = gears.timer({
    timeout     = 1,
    autostart   = false,
    single_shot = false,
    callback    = pomodoro.update_widget,
    call_now    = true
})

function pomodoro.toggle()
    pomodoro.widget.visible = not pomodoro.widget.visible
end

function pomodoro.change_state()
    pomodoro.timer:stop()

    local message = ""
    if state == STATE.WORK then
        message = "Time to break!"
        state = STATE.BREAK
        time_to_end = STATE.BREAK + 1
        pomodoro.widget.fg = beautiful.pomodoro_break_widget_fg
        pomodoro.widget.bg = beautiful.pomodoro_break_widget_bg
    else
        message = "Time to do some work!"
        state = STATE.WORK
        time_to_end = STATE.WORK + 1
        pomodoro.widget.fg = beautiful.pomodoro_work_widget_fg
        pomodoro.widget.bg = beautiful.pomodoro_work_widget_bg
    end
    pomodoro_notify(message)
    pomodoro.update_widget()
end

function pomodoro.reset_state()
    pomodoro.timer:stop()
    if state == STATE.WORK then
        time_to_end = STATE.WORK + 1
    else
        time_to_end = STATE.BREAK + 1
    end
    pomodoro.update_widget()
    pomodoro_notify("Reseted!")
end

function pomodoro.start_pause()
    if pomodoro.timer.started then
        pomodoro.timer:stop()
    else
        pomodoro.timer:start()
        pomodoro.update_widget()
    end
end

pomodoro.widget:buttons(gears.table.join(
    awful.button({ }, 1, pomodoro.start_pause),
    awful.button({ }, 2, pomodoro.change_state),
    awful.button({ }, 3, pomodoro.reset_state)
))

return pomodoro
