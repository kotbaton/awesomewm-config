local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful") 
local dpi       = require("beautiful.xresources").apply_dpi

local user = require("settings").user

---- CPU Temperature ----
local cpu_temp = wibox.widget {
    align         = 'center',
    text          = 'CPU temp: ',
    widget        = wibox.widget.textbox,
    forced_height = dpi(24)
}

local function cpu_temp_update(widget)
    local command = "sensors coretemp-isa-0000 -u"
    awful.spawn.easy_async(command, function(stdout)
        local temp = stdout:match("%d+", 61)
        widget.text = "CPU temp: +" .. temp .. "°C"
    end)
end

---- RAM text and bar ----
local ram_text = wibox.widget {
    align  = 'center',
    text   = 'RAM: ',
    widget = wibox.widget.textbox
}

local ram_bar = wibox.widget {
    max_value        = 1,
    value            = 0,
    border_width     = beautiful.si_inner_border_width or 1,
    border_color     = beautiful.si_inner_border_color or beautiful.colors.darkGrey,
    color            = beautiful.si_ram_bar_fg or beautiful.colors.green .. '99',
    background_color = beautiful.si_bg or beautiful.colors.black,
    paddings         = dpi(2),
    forced_height    = dpi(24),
    forced_width     = dpi(200),
    widget           = wibox.widget.progressbar,
}

local function ram_update(text_widget, bar_widget)
    local command = "free -m"
    awful.spawn.easy_async(command, function(stdout)
            local total, used, free, shared, buff, available =
                stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
            bar_widget:set_value((used+shared)/total)

            used = string.format("%0.2fG", (used+shared)/1024)
            total = string.format("%0.2fG", total/1024)
            text_widget:set_text("RAM: " .. used .. "/" .. total)
    end)
end

---- CPU load graph ----
local cpu_graph = wibox.widget {
    max_value        = 100,
    background_color = beautiful.si_bg or beautiful.colors.black,
    color            = beautiful.si_cpu_graph_fg or beautiful.colors.lightGreen,
    border_color     = beautiful.si_inner_border_color or beautiful.colors.darkGrey,
    border_width     = beautiful.si_inner_border_width or dpi(1),
    forced_height    = dpi(24),
    forced_width     = dpi(200),
    step_width       = dpi(4),
    step_spacing     = dpi(2),
    widget           = wibox.widget.graph,
}

local total_prev, idle_prev = 0, 0
local function cpu_graph_update(graph_widget)
    local command = "cat /proc/stat | grep '^cpu '"
    awful.spawn.easy_async(command, function(stdout)
        local user, nice, system, idle, iowait, irq, softirq, steal, _, _ =
            stdout:match('(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s')

        local total = user + nice + system + idle + iowait + irq + softirq + steal

        local diff_idle = idle - idle_prev
        local diff_total = total - total_prev
        local diff_usage = (1000*(diff_total-diff_idle)/diff_total+5)/10

        graph_widget:add_value(diff_usage)

        total_prev = total
        idle_prev = idle
    end)
end

---- Processes ----
local ps_text = wibox.widget {
    align        = 'left',
    valign       = 'center',
    text         = '',
    forced_width = dpi(200),
    widget       = wibox.widget.textbox
}

local function ps_update(widget)
    local command = [[bash -c "ps -e --sort=-pcpu -o pid,pcpu,comm | head -n 6 | cut -c-22" ]]
    awful.spawn.easy_async(command, function(stdout)
        widget.text = stdout
    end)
end

---- Calendar format function ----
local calendar_styles = {
    month = {
        padding      = dpi(2),
        bg_color     = beautiful.colors.black,
        border_width = dpi(1),
    },
    normal = {
        border_width = dpi(1),
    },
    focus = {
        border_width = dpi(1),
        fg_color     = beautiful.colors.black,
        bg_color     = beautiful.colors.green,
    },
    header = {
        fg_color = beautiful.colors.green,
        bg_color = beautiful.colors.black,
        markup   = function(t) return '<b>' .. t .. '</b>' end,
    },
    weekday = {
        fg_color = beautiful.colors.green,
        markup   = function(t) return '<b>' .. t .. '</b>' end,
    },
}

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

local calendar_month = wibox.widget {
    date         = os.date('*t'),
    week_numbers = false,
    start_sunday = false,
    fn_embed     = decorate_calendar,
    widget       = wibox.widget.calendar.month,
}

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
    end)))

---- Weather widget ----
local weather_text = wibox.widget {
    align         = 'center',
    valign        = 'center',
    text          = '...',
    forced_width  = dpi(200),
    forced_height = dpi(24),
    wrap          = 'word',
    widget        = wibox.widget.textbox
}

local function weather_update(text_widget)
    local key = user.api_key
    local city_id = user.city_id
    local command = [[
        bash -c '
        KEY="]]..key..[["
        CITY="]]..city_id..[["

        weather=$(curl -sf "http://api.openweathermap.org/data/2.5/weather?APPID=$KEY&id=$CITY&units=metric")

        if [ ! -z "$weather" ]; then
            weather_temp=$(echo "$weather" | jq ".main.temp" | cut -d "." -f 1)
            weather_description=$(echo "$weather" | jq -r ".weather[].description" | head -1)

            echo "$weather_temp°, $weather_description"
        else
            echo "..."
        fi
  ']]
    awful.spawn.easy_async(command, function(stdout)
        text_widget:set_text(stdout)
        if string.len(stdout) <= 23 then
            text_widget:set_forced_height(dpi(24))
        else
            text_widget:set_forced_height(dpi(48))
        end
    end)
end

---- Timer ----
local si = {}
si.timer = gears.timer({
    timeout = 1,
    callback = function()
        cpu_temp_update(cpu_temp)
        ram_update(ram_text, ram_bar)
        cpu_graph_update(cpu_graph)
        ps_update(ps_text)
    end,
})

-- Function which adds border around widget
local function decorator(w)
    return {
        w,
        shape              = gears.shape.rectangle,
        shape_border_color = beautiful.si_inner_border_color or beautiful.colors.darkGrey,
        shape_border_width = beautiful.si_inner_border_width or dpi(1),
        widget             = wibox.container.background
    }
end

si.popup = awful.popup {
    widget = {
        {
            decorator(weather_text),
            {
                cpu_graph,
                reflection = { horizontal = true },
                widget = wibox.container.mirror,
            },
            decorator(ps_text),
            {
                ram_bar,
                ram_text,
                layout = wibox.layout.stack,
            },
            decorator(cpu_temp),
            calendar_month,
            spacing = 8,
            layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(8),
        widget  = wibox.container.margin
    },
    opacity             = 0.8,
    border_color        = beautiful.si_outer_border_color or beautiful.colors.green,
    border_width        = beautiful.si_outer_border_width or dpi(2),
    placement           = awful.placement.top_right + awful.placement.no_offscreen,
    shape               = gears.shape.rect,
    visible             = false,
    ontop               = true,
}

si.popup:buttons(gears.table.join(awful.button({}, 1, function()
    si.toggle()
end)))

function si.toggle()
    if not si.timer.started then
        si.timer:start()
        si.popup.screen = awful.screen.focused()
        weather_update(weather_text)
        calendar_month:set_date(os.date('*t'))
        si.popup.visible = true
    else
        si.timer:stop()
        si.popup.visible = false
        collectgarbage('collect')
    end
end

return si
