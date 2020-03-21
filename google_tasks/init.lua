local awful             = require('awful')
local gears             = require('gears')
local wibox             = require('wibox')
local beautiful         = require('beautiful')
local dpi               = require('beautiful.xresources').apply_dpi

local cjson             = require('cjson')

local list_item         = require('google_tasks.list_item')

local base_command = gears.filesystem.get_configuration_dir() .. 'google_tasks/google_tasks.py'

local tasklists = nil
local current_tasklist = nil
local tasklist_choose_menu = nil
local cached_lists = {}

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


local function update_list_with_items(tasklist, items)
    tasklist_title:set_text(tasklist.title)
    tasklist_widget:reset()
    if items then
        for i in pairs(items) do
            tasklist_widget:add(list_item(tasklist, items[i]))
        end
    else
        tasklist_widget:add(wibox.widget {
            text = 'This tasklist is empty',
            align  = 'center',
            valign = 'center',
            widget = wibox.widget.textbox,
        })
    end
end

local function update_tasklist_widget()
    tasklist_title:set_text('Updating...')
    if current_tasklist then
        if cached_lists[current_tasklist] == nil then
            local command = base_command .. ' --list ' .. current_tasklist.id
            awful.spawn.easy_async(command, function(stdout, stderr)
                local result = cjson.decode(stdout)
                update_list_with_items(current_tasklist, result.items)
                cached_lists[current_tasklist] = result
            end)
        else
            update_list_with_items(current_tasklist,
                                   cached_lists[current_tasklist].items)
        end
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
        tasklist_widget,
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
