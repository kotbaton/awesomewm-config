local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful") 
local dpi       = require("beautiful.xresources").apply_dpi

-- Definitions of calendar styles
local calendar_styles = {
    month = {
        padding      = dpi(2),
        bg_color     = beautiful.si_inner_bg or beautiful.colors.black,
        border_width = beautiful.si_inner_border_width or dpi(1),
        border_color = beautiful.si_inner_border_color or beautiful.colors.darkGrey,
        shape        = beautiful.si_outer_border_shape,
    },
    normal = {
        border_width = dpi(0),
        bg_color     = '#00000000',
    },
    focus = {
        border_width = dpi(0),
        fg_color     = beautiful.colors.black,
        bg_color     = beautiful.colors.green,
        shape        = beautiful.si_outer_border_shape,
    },
    header = {
        fg_color = beautiful.colors.green,
        bg_color = '#00000000',
        markup   = function(t) return '<b>' .. t .. '</b>' end,
    },
    weekday = {
        fg_color = beautiful.colors.green,
        bg_color = '#00000000',
        markup   = function(t) return '<b>' .. t .. '</b>' end,
    },
}

-- Function which applies styles to widget
local function decorate_calendar(widget, flag, date)
    if flag=='monthheader' and not calendar_styles.monthheader then
        flag = 'header'
    end
    local props = calendar_styles[flag] or {}
    if props.markup and widget.get_text and widget.set_markup then
        widget:set_markup(props.markup(widget:get_text()))
    end
    -- Change bg color for weekends
    local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
    local weekday = tonumber(os.date('%w', os.time(d)))
    local default_bg = (weekday==0 or weekday==6) and beautiful.colors.darkGrey or beautiful.colors.black
    local ret = wibox.widget {
        {
            widget,
            margins = (props.padding or 2) + (props.border_width or 0),
            widget  = wibox.container.margin
        },
        shape              = props.shape or gears.shape.rectangle,
        shape_border_color = props.border_color or beautiful.colors.darkGrey,
        shape_border_width = props.border_width or 0,
        fg                 = props.fg_color or beautiful.colors.white,
        bg                 = props.bg_color or default_bg,
        widget             = wibox.container.background
    }
    return ret
end

-- Calendar widget itself
local calendar_month = wibox.widget {
    font         = beautiful.calendar_font or beautiful.font,
    date         = os.date('*t'),
    week_numbers = false,
    start_sunday = false,
    fn_embed     = decorate_calendar,
    widget       = wibox.widget.calendar.month,
}

-- Callback to scroll monthes
local function calendar_update(modifier)
    local new_month = calendar_month.date.month + modifier
        local cur_month = os.date('*t').month
        if cur_month == new_month then
            calendar_month:set_date(os.date('*t'))
        else
            calendar_month:set_date({
                month = new_month,
                year = calendar_month.date.year
            })
        end
end

calendar_month:buttons(gears.table.join(
    awful.button({}, 4, function()
        calendar_update(-1)
    end),
    awful.button({}, 5, function()
        calendar_update(1)
    end)
))

return {
    widget = calendar_month,
    update = function() 
        calendar_month:set_date(os.date('*t'))
    end,
}
