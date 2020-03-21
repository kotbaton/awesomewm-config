local awful             = require('awful')
local gears             = require('gears')
local wibox             = require('wibox')
local beautiful         = require('beautiful')
local dpi               = require('beautiful.xresources').apply_dpi

local cjson             = require('cjson')

local list_item         = require('google_tasks.list_item')

local base_command = gears.filesystem.get_configuration_dir() .. 'google_tasks/google_tasks.py'

local google_tasks = {}

local cache = {
    tasklists = nil,
    current_tasklist = nil,
    tasklist_choose_menu = nil,
    lists = {}
}

function new(args)
    local tasklist_title = wibox.widget {
        text   = 'Updating...',
        align  = 'center',
        valign = 'center',
        font   = 'Hermit Bold 13', -- TODO
        widget = wibox.widget.textbox
    }

    local tasklist_body = wibox.widget {
        spacing = dpi(4),
        layout = wibox.layout.fixed.vertical,
    }

    local function update_widget(tasklist, items)
        tasklist_title:set_text(tasklist.title)
        tasklist_body:reset()
        if items then
            for i in pairs(items) do
                tasklist_body:add(list_item(tasklist, items[i]))
            end
        else
            tasklist_body:add(wibox.widget {
                text = 'This tasklist is empty',
                align  = 'center',
                valign = 'center',
                widget = wibox.widget.textbox,
            })
        end
    end

    local function update_tasklist_menu()
        -- Put into cache awful.menu with tasklist choose options
        local menu_entries = {}
        for i in pairs(cache.tasklists.items) do
            menu_entries[i] = {
                cache.tasklists.items[i].title,
                function()
                    if cache.current_tasklist == cache.tasklists.items[i] then
                        return
                    end
                    cache.current_tasklist = cache.tasklists.items[i]
                    update_widget(cache.current_tasklist,
                                  cache.lists[cache.current_tasklist].items)
                end
            }
        end
        cache.tasklist_choose_menu = awful.menu(menu_entries)
    end

    local function get_list(tasklist)
        -- Get tasks from tasklist and save it into cache
        local command = base_command .. ' --list ' .. tasklist.id
        awful.spawn.easy_async(command, function(stdout, stderr)
            local result = cjson.decode(stdout)
            cache.lists[tasklist] = result

            awesome.emit_signal('tasks::ready', tasklist)
        end)
    end

    local function get_all_tasklists()
        -- Get remote info about all tasklists and save it into cache
        local command = base_command .. ' --all'
        awful.spawn.easy_async(command, function(stdout, stderr)
            cache.tasklists = cjson.decode(stdout)
            cache.current_tasklist = cache.tasklists.items[1]

            for i, tasklist in ipairs(cache.tasklists.items) do
                get_list(tasklist)
            end
        end)
    end

    tasklist_title:buttons(awful.button({}, 1, function()
        if not cache.tasklist_choose_menu and cache.tasklists then
            update_tasklist_menu()
        end
        cache.tasklist_choose_menu:toggle()
    end))

    local timer = gears.timer {
        timeout   = 300,
        autostart = true,
        call_now  = true,
        callback  = function()
            get_all_tasklists()
        end
        }

    awesome.connect_signal('tasks::update_needed', function()
        get_list(cache.current_tasklist)
    end)

    awesome.connect_signal('tasks::ready', function(tasklist)
        if tasklist == cache.current_tasklist then
                    update_widget(cache.current_tasklist,
                                  cache.lists[cache.current_tasklist].items)
        end
    end)

    -- Actually a widget
    google_tasks = {
        {
            tasklist_title,
            fg     = beautiful.colors.purple,
            widget = wibox.container.background,
        },
        tasklist_body,
        layout = wibox.layout.fixed.vertical,
    }

    return google_tasks
end

return setmetatable(google_tasks, {__call = function(_, ...) return new(...) end})
