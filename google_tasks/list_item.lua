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
        check_color        = beautiful.colors.purple,
        shape              = gears.shape.circle,
        paddings           = dpi(3),
        border_width       = dpi(2),
        forced_height      = dpi(20),
        forced_width       = dpi(20),
        widget = wibox.widget.checkbox
    }

    local title_widget = wibox.widget {
        text   = task.title,
        align  = 'left',
        valign = 'top',
        font = 'Hermit 10', -- TODO
        forced_height = (task.notes ~= nil) and dpi(20) or nil,
        widget = wibox.widget.textbox
    }

    local notes_widget = wibox.widget {
        text   = task.notes,
        align  = 'left',
        valign = 'top',
        wrap   = 'word',
        font = 'Hermit 9', -- TODO
        widget = wibox.widget.textbox
    }

    local due_widget = nil
    if task.due then
        local y, m, d = task.due:match('(%d+)-(%d+)-(%d+)')
        due_widget = wibox.widget {
            {
                text   = ' ' .. d .. '.' .. m .. '.' .. y .. ' ',
                align  = 'left',
                valign = 'top',
                font = 'Hermit 10', -- TODO
                widget = wibox.widget.textbox
            },
            fg = beautiful.colors.white,
            bg = beautiful.colors.red .. 'AA',
            shape = function(cr, width, height)
                gears.shape.rounded_bar(cr, width, height, 8)
            end,
            widget = wibox.container.background
        }
    end

    local body_widget = wibox.widget {
        title_widget,
        {
            due_widget,
            {
                notes_widget,
                fg = beautiful.colors.grey,
                widget = wibox.container.background
            },
            spacing = dpi(4),
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.fixed.vertical,
    }

    body_widget:buttons(awful.button({}, 1, function()
        awesome.emit_signal('tasks::edit', tasklist, task)
    end))

    checkbox:buttons(awful.util.table.join(awful.button({}, 1, function()
        checkbox:set_checked(true)
        command = base_command .. ' --mark_as_completed '
                               .. task.id .. ' ' .. tasklist.id
        awful.spawn.easy_async(command, function(stdout)
            awesome.emit_signal('tasks::update_needed')
        end)
    end)))

    list_item = wibox.widget {
        checkbox,
        body_widget,
        spacing = dpi(8),
        forced_height = dpi(40),
        layout = wibox.layout.fixed.horizontal,
    }

    return list_item
end

return setmetatable(list_item, {__call = function(_, ...) return new(...) end})
