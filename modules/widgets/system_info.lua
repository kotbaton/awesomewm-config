local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful") 
local dpi       = require("beautiful.xresources").apply_dpi

local user = require("settings").user

-- Helper functions
local function decorator(w, vmargin, hmargin, fg)
    return {
        {
            w,
            bg                 = beautiful.si_inner_bg,
            fg                 = fg or beautiful.fg_normal,
            shape_border_color = beautiful.si_inner_border_color or beautiful.colors.darkGrey,
            shape_border_width = beautiful.si_inner_border_width or dpi(1),
            widget             = wibox.container.background
        },
        forced_width    = dpi(200),
        top             = vmargin or dpi(2),
        bottom          = vmargin or dpi(2),
        left            = hmargin or dpi(20),
        right           = hmargin or dpi(20),
        widget          = wibox.container.margin,
    }
end

local function add_label(label, widget, label_size)
    label_size = label_size or 15
    return {
        {
            text            = label,
            font            = "Hermit " .. label_size,
            align           = 'center',
            valign          = 'center',
            forced_width    = dpi(50),
            forced_height   = dpi(32),
            widget          = wibox.widget.textbox,
        },
        widget,
        layout = wibox.layout.align.horizontal,
    }
end

---- Sensors widget ----
local sensors_widget = wibox.widget {
    align         = 'center',
    text          = "Wait for update...",
    wrap          = "word",
    font          = beautiful.si_temp_font or beautiful.font,
    widget        = wibox.widget.textbox,
    forced_height = dpi(50)
}
local function sensors_update(widget)
    local command = [[
    bash -c 't1=$(sensors coretemp-isa-0000 -u | grep -Eom 1 --color=never "[0-9]{2}\.[0-9]")

    echo "$t1"
    ']]
    awful.spawn.easy_async(command, function(stdout)
        local cpu = stdout:match("(%d+).0")
        widget:set_text("CPU temp: +" .. cpu .. "°C")
    end)
end

---- RAM bar ----
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

local function ram_update(bar_widget, bar_widget_swap)
    local command = "free -m"
    awful.spawn.easy_async(command, function(stdout)
            local total, used, free, shared, buff, available, total_swap, used_swap, _ =
                stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
            bar_widget:set_value((used+shared)/total)
            bar_widget_swap:set_value(used_swap/total_swap)

            used = string.format("%0.2fG", (used+shared)/1024)
            total = string.format("%0.2fG", total/1024)

            used = string.format("%0.2fG", used_swap/1024)
            total = string.format("%0.2fG", total_swap/1024)
    end)
end

---- CPU load graph ----
local cpu_graph = wibox.widget {
    max_value        = 100,
    background_color = beautiful.si_cpu_graph_bg or beautiful.colors.black,
    color            = beautiful.si_cpu_graph_fg or beautiful.colors.lightGreen,
    border_color     = beautiful.si_inner_border_color or beautiful.colors.darkGrey,
    border_width     = beautiful.si_inner_border_width or dpi(1),
    forced_height    = dpi(32),
    forced_width     = dpi(200),
    step_width       = dpi(6),
    step_spacing     = dpi(2),
    widget           = wibox.widget.graph,
}
local cpu_label = wibox.widget {
    {
        text = "",
        font = "Hermit 15",
        align = 'center',
        forced_width = dpi(50),
        widget = wibox.widget.textbox,
    },
    fg = beautiful.colors.green,
    widget = wibox.widget.background,
}

local total_prev, idle_prev = 0, 0
local function cpu_graph_update(graph_widget, label)
    local command = "cat /proc/stat | grep '^cpu '"
    awful.spawn.easy_async(command, function(stdout)
        local user, nice, system, idle, iowait, irq, softirq, steal, _, _ =
            stdout:match('(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s')

        local total = user + nice + system + idle + iowait + irq + softirq + steal

        local diff_idle = idle - idle_prev
        local diff_total = total - total_prev
        local diff_usage = (1000*(diff_total-diff_idle)/diff_total+5)/10

        graph_widget:add_value(diff_usage)

        if diff_usage <= 25 then
            graph_widget.color = beautiful.colors.green
            label.fg = beautiful.colors.green
        elseif diff_usage > 25 and diff_usage <= 75 then
            graph_widget.color = beautiful.colors.yellow
            label.fg = beautiful.colors.yellow
        else
            graph_widget.color = beautiful.colors.red
            label.fg = beautiful.colors.red
        end

        total_prev = total
        idle_prev = idle
    end)
end

---- Calendar format function ----
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
    font         = beautiful.calendar_font or beautiful.font,
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
    forced_height = dpi(80),
    wrap          = 'word',
    font          = beautiful.si_weather_widget_font or beautiful.font,
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

            echo -e "Current weather:\n$weather_temp°, $weather_description"
        else
            echo "..."
        fi
  ']]
    awful.spawn.easy_async(command, function(stdout)
        text_widget:set_text(stdout)
    end)
end

---- Timer ----
local si = {}
si.timer = gears.timer({
    timeout = 1,
    callback = function()
        sensors_update(sensors_widget)
        ram_update(ram_bar, swap_bar)
        cpu_graph_update(cpu_graph, cpu_label)
    end,
})

si.popup = wibox({
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

si.popup:setup{
    {
        decorator(weather_text, dpi(16)),
        layout = wibox.layout.fixed.vertical,
    },
    {
        decorator({
            cpu_label,
            {
                cpu_graph,
                reflection = { horizontal = true },
                widget = wibox.container.mirror,
            },
            layout = wibox.layout.fixed.horizontal,
        }),
        decorator(add_label("", ram_bar), nil, nil, beautiful.colors.green),
        decorator(add_label("", swap_bar), nil, nil, beautiful.colors.yellow),
        decorator(add_label("", sensors_widget, 20)),

        spacing = dpi(8),
        layout = wibox.layout.fixed.vertical,
    },
    {
        decorator(calendar_month, nil, dpi(35)),
        layout = wibox.layout.fixed.vertical,
    },
    layout = wibox.layout.align.vertical,
}

si.popup:buttons(gears.table.join(awful.button({}, 1, function()
    si.toggle()
end)))

function si.toggle()
    if not si.timer.started then
        si.timer:start()
        weather_update(weather_text)
        calendar_month:set_date(os.date('*t'))

        local fscreen = awful.screen.focused()
        local geo = fscreen.geometry
        si.popup.screen = fscreen
        si.popup.height = geo.height - dpi(24)
        si.popup.y = geo.y + dpi(24)
        si.popup.x = geo.x + geo.width - dpi(300)
        si.popup.visible = true
    else
        si.timer:stop()
        si.popup.visible = false
        collectgarbage('collect')
    end
end

return si
