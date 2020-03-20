local awful             = require('awful')
local gears             = require('gears')
local wibox             = require('wibox')
local beautiful         = require('beautiful')
local dpi               = require('beautiful.xresources').apply_dpi

local cjson             = require('cjson')

local tasks = {
    widget = nil,
    update = nil,
}

local function task_widget(item)
    return wibox.widget {
        {
            checked       = false,
            color         = beautiful.colors.white,
            shape         = gears.shape.circle,
            paddings      = dpi(2),
            check_border_width = dpi(2),
            forced_height = dpi(24),
            forced_width  = dpi(24),
            widget = wibox.widget.checkbox,
        },
        {
            markup = item.title,
            align  = 'left',
            valign = 'center',
            widget = wibox.widget.textbox
        },
        spacing = dpi(8),
        forced_height = dpi(32),
        layout = wibox.layout.fixed.horizontal,
    }
end

tasks.widget = wibox.widget {
        {
            markup = 'Todo',
            align  = 'center',
            valign = 'center',
            widget = wibox.widget.textbox
        },
        spacing = dpi(4),
        layout = wibox.layout.fixed.vertical,
    }

local function construct_list_widget(items)
    for i in pairs(items) do
        tasks.widget:add(task_widget(items[i]))
    end
end

function tasks.update()
    local command = [[python /home/sheh/works/google-tasks/tasks.py RGE4eUlkQnRjTExibWVlSA]]
    awful.spawn.easy_async(command, function(stdout, stderr)
        local result = cjson.decode(stdout)

        construct_list_widget(result.items)
    end)
end

tasks.update()

return tasks
