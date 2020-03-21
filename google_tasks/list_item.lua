local awful             = require('awful')
local gears             = require('gears')
local wibox             = require('wibox')
local beautiful         = require('beautiful')
local dpi               = require('beautiful.xresources').apply_dpi

local base_command = gears.filesystem.get_configuration_dir() .. 'google_tasks/google_tasks.py'

local list_item = {}

local function new(tasklist, task)
    local checkbox = wibox.widget {
        checked            = false,
        color              = beautiful.colors.white,
        shape              = gears.shape.circle,
        paddings           = dpi(3),
        border_width       = dpi(2),
        forced_height      = dpi(20),
        forced_width       = dpi(20),
        widget = wibox.widget.checkbox
    }

    local body_widget = {
        text   = task.title,
        align  = 'left',
        valign = 'center',
        forced_height = dpi(24),
        widget = wibox.widget.textbox
    }
    local notes_widget = {
        text   = task.notes,
        align  = 'left',
        valign = 'center',
        forced_height = dpi(16),
        font = 'Hermit 10', -- TODO
        widget = wibox.widget.textbox
    }

    list_item = wibox.widget {
        checkbox,
        {
            body_widget,
            {
                notes_widget,
                fg = beautiful.colors.grey,
                widget = wibox.container.background
            },
            layout = wibox.layout.fixed.vertical,
        },
        forced_height = not task.notes and dpi(32) or dpi(40),
        spacing = dpi(8),
        layout = wibox.layout.fixed.horizontal,
    }

    checkbox:buttons(awful.util.table.join(awful.button({}, 1, function()
        checkbox:set_checked(true)
        command = base_command .. ' --mark_as_completed '
                               .. task.id .. ' ' .. tasklist.id
        awful.spawn.easy_async(command, function(stdout)
            awesome.emit_signal('tasks::update_needed')
        end)
    end)))

    return list_item
end

return setmetatable(list_item, {__call = function(_, ...) return new(...) end})
