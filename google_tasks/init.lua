local awful             = require('awful')
local gears             = require('gears')
local wibox             = require('wibox')
local beautiful         = require('beautiful')
local dpi               = require('beautiful.xresources').apply_dpi

local cjson             = require('cjson')

local base_command = gears.filesystem.get_configuration_dir() .. 'google_tasks/google_tasks.py'

local tasklists = nil
local current_tasklist = nil
local tasklist_choose_menu = nil

local function new_task_widget(item)
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
            text   = item.title,
            align  = 'left',
            valign = 'center',
            widget = wibox.widget.textbox
        },
        spacing = dpi(8),
        forced_height = dpi(24),
        layout = wibox.layout.fixed.horizontal,
    }
end

local tasklist_widget = wibox.widget {
    spacing = dpi(4),
    layout = wibox.layout.fixed.vertical,
}

local tasklist_title = wibox.widget {
    text   = 'Updating...',
    align  = 'center',
    valign = 'center',
    font   = 'Hermit Bold 13', -- TODO
    widget = wibox.widget.textbox
}

local scrollable_widget = wibox.widget {
    tasklist_widget,
    step_function = wibox.container.scroll.step_functions
                    .linear_back_and_forth,
    speed = 100,
    layout = wibox.container.scroll.vertical
}

scrollable_widget:set_fps(30)


local function update_list_with_items(tasklist, items)
    tasklist_title:set_text(tasklist.title)
    tasklist_widget:reset()
    for i in pairs(items) do
        tasklist_widget:add(new_task_widget(items[i]))
    end
end

local function update_tasklist_widget()
    if current_tasklist then
        tasklist_title:set_text('Updating...')

        local command = base_command .. ' --list ' .. current_tasklist.id
        awful.spawn.easy_async(command, function(stdout, stderr)
            local result = cjson.decode(stdout)
            update_list_with_items(current_tasklist, result.items)
        end)
    end
end

local function update_lists_info()
    -- Get all tasklists info
    local command = base_command .. ' --all'
    awful.spawn.easy_async(command, function(stdout, stderr)
        tasklists = cjson.decode(stdout)
        current_tasklist = tasklists.items[1]

        update_tasklist_widget()
    end)
end

local function toggle_menu()
    if not tasklist_choose_menu then
        local menu_entries = {}
        for i in pairs(tasklists.items) do
            menu_entries[i] = {
                tasklists.items[i].title,
                function()
                    if current_tasklist == tasklists.items[i] then
                        return
                    end
                    current_tasklist = tasklists.items[i]
                    update_tasklist_widget()
                end
            }
        end
        tasklist_choose_menu = awful.menu(menu_entries)
    end
    tasklist_choose_menu:toggle()
end

tasklist_title:buttons(awful.button({}, 1, function()
    toggle_menu()
end))

return {
    widget = {
        {
            tasklist_title,
            fg     = beautiful.colors.orange,
            widget = wibox.container.background,
        },
        scrollable_widget,
        layout = wibox.layout.fixed.vertical,
    },
    update = function()
        if not tasklists then
            update_lists_info()
        else
            update_tasklist_widget()
        end
    end,
}
