local awful             = require('awful')
local gears             = require('gears')
local wibox             = require('wibox')
local beautiful         = require('beautiful')
local naughty           = require('naughty')
local dpi               = require('beautiful.xresources').apply_dpi

local cjson             = require('cjson')

local list_item         = require('google_tasks.list_item')

local base_command = gears.filesystem.get_configuration_dir() .. 'google_tasks/google_tasks.py'

local google_tasks = {}

local tasks_on_page = 4
local page = {
    first = 1,
    last = nil,
}

local cache = {
    tasklists = nil,
    current_tasklist = nil,
    tasklist_choose_menu = nil,
    lists = {},
}

function new(args)
    local tasklist_title = wibox.widget {
        text   = 'Updating...',
        align  = 'center',
        valign = 'center',
        font   = 'Hermit Bold 13', -- TODO
        widget = wibox.widget.textbox
    }

    local tasklist_sync_button = wibox.widget {
        text   = '  ',
        align  = 'center',
        valign = 'center',
        font   = 'Hermit Bold 15', -- TODO
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
            -- for i in pairs(items) do
            page.first = 1
            page.last = #items < tasks_on_page and #items or tasks_on_page
            for i = page.first, page.last do
                tasklist_body:add(list_item(tasklist, items[i]))
            end
        else
            tasklist_body:add(wibox.widget {
                text   = 'There is nothing to do',
                align  = 'center',
                valign = 'center',
                widget = wibox.widget.textbox,
            })
        end
    end

    local function update_tasklist_menu()
        -- Put into cache awful.menu with tasklist choose options
        local menu_entries = {}
        for i, tasklist in ipairs(cache.tasklists.items) do
            menu_entries[i] = {
                tasklist.title,
                function()
                    if cache.current_tasklist == tasklist then
                        return
                    end
                    cache.current_tasklist = tasklist
                    update_widget(cache.current_tasklist,
                                  cache.lists[cache.current_tasklist.id].items)
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
            cache.lists[tasklist.id] = result

            awesome.emit_signal('tasks::ready', tasklist)
        end)
    end

    local function get_all_tasklists()
        -- Get remote info about all tasklists and save it into cache
        local command = base_command .. ' --all'
        awful.spawn.easy_async(command, function(stdout, stderr)
            if stdout == '' or stdout == nil then
                naughty.notify {
                    title = "Google Tasks",
                    text = "Synchronization fails.",
                }
                return
            end

            cache.tasklists = cjson.decode(stdout)
            if not cache.current_tasklist then
                cache.current_tasklist = cache.tasklists.items[1]
            end

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

    tasklist_sync_button:buttons(awful.button({}, 1, function()
        tasklist_title:set_text('Updating...')
        get_all_tasklists()
        update_tasklist_menu()
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
        tasklist_title:set_text('Updating...')
        get_list(cache.current_tasklist)
    end)

    awesome.connect_signal('tasks::ready', function(tasklist)
        if tasklist.id == cache.current_tasklist.id then
            update_widget(tasklist,
                          cache.lists[tasklist.id].items)
        end
    end)

    tasklist_body:buttons(
        gears.table.join(
            awful.button({}, 4, function()
                local cur_items = cache.lists[cache.current_tasklist.id].items

                -- Don't scroll in this case
                if #cur_items < tasks_on_page then return end

                -- Scroll if we can
                if page.first > 1 and page.last <= #cur_items then
                    page.first = page.first - 1
                    page.last = page.last - 1

                    tasklist_body:remove(tasks_on_page)
                    tasklist_body:insert(1, list_item(cache.current_tasklist,
                                                      cur_items[page.first]))
                end

            end),
            awful.button({}, 5, function()
                local cur_items = cache.lists[cache.current_tasklist.id].items

                -- Don't scroll in this case
                if #cur_items < tasks_on_page then return end

                -- Scroll if we can
                if page.first >= 1 and page.last < #cur_items then
                    page.first = page.first + 1
                    page.last = page.last + 1
                    tasklist_body:remove(1)
                    tasklist_body:add(list_item(cache.current_tasklist,
                                                cur_items[page.last]))
                end
            end))
    )

    -- Actually a widget
    google_tasks = {
        {
            {
                nil,
                tasklist_title,
                tasklist_sync_button,
                forced_height = dpi(30),
                layout = wibox.layout.align.horizontal
            },
            fg     = beautiful.colors.purple,
            widget = wibox.container.background,
        },
        {
            tasklist_body,
            widget = wibox.container.background,
        },
        layout = wibox.layout.fixed.vertical,
    }

    return google_tasks
end

return setmetatable(google_tasks, {__call = function(_, ...) return new(...) end})
