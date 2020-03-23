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

-- [[ TODO: Try insert this section into new() function,
-- so tasks_on_page can be setted by arguments
local tasks_on_page = 4 -- TODO: Move this somewhere
local page = {
    first = 1,
    last = nil,
}
-- ]]

local cache = {
    tasklists = nil,
    current_tasklist = nil,
    tasklist_choose_menu = nil,
    lists = {},
}

local function raise_error_notification()
    naughty.notify {
        title = "Google Tasks",
        text = "Synchronization fails.",
    }
end


local function button_decorator(widget, args)
    args = args or {}
    local res = wibox.widget {
        widget or nil,
        fg     = args.fg or beautiful.colors.purple,
        bg     = args.bg or nil,
        shape  = args.shape or function(cr, width, height)
            gears.shape.rounded_bar(cr, width, height, 8)
        end,
        widget = wibox.container.background,
    }
    res:connect_signal('mouse::enter', function()
        res.fg = args.fg_hover or beautiful.colors.lightPurple
        res.bg = args.bg_hover or nil
    end)
    res:connect_signal('mouse::leave', function()
        res.fg = args.fg or beautiful.colors.purple
        res.bg = args.bg or nil
    end)
    return res
end


local function new(args)
    local add_task_button = wibox.widget {
        text   = '  ',
        align  = 'center',
        valign = 'center',
        font   = 'Hermit Bold 15', -- TODO
        widget = wibox.widget.textbox
    }

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

    local tasklist_prompt = awful.widget.prompt {
        fg = beautiful.colors.purple,
        history_max = 0,
    }

    local tasklist_body = wibox.widget {
        spacing = dpi(4),
        layout = wibox.layout.fixed.vertical,
    }

    local function update_widget(tasklist, items)
        tasklist_title:set_text(tasklist.title)
        tasklist_body:reset()
        if items then
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
                raise_error_notification()
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

    add_task_button:buttons(awful.button({}, 1, function()
        awful.prompt.run {
            prompt       = 'Add task: ',
            textbox      = tasklist_prompt.widget,
            bg_cursor = beautiful.colors.purple,
            fg_cursor = beautiful.colors.purple,
            exe_callback = function(text)
                tasklist_title:set_text('Adding...')
                -- Save in case of changing current tasklist until we save task
                local cur_tasklist_id = cache.current_tasklist.id
                local command = base_command .. ' --insert '
                                .. cur_tasklist_id .. ' "'
                                .. text .. '" ""'
                awful.spawn.easy_async(command, function(stdout, stderr)
                    if stdout == '' or stdout == nil then
                        raise_error_notification()
                        return
                    end
                    local new_task = cjson.decode(stdout)
                    table.insert(cache.lists[cur_tasklist_id].items, 1, new_task)
                    if cache.current_tasklist.id == cur_tasklist_id then
                        update_widget(cache.current_tasklist,
                                      cache.lists[cache.current_tasklist.id].items)
                    end
                end)
            end
        }
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
            button_decorator(add_task_button),
            button_decorator(tasklist_title),
            button_decorator(tasklist_sync_button),
            forced_height = dpi(30),
            layout = wibox.layout.align.horizontal
        },
        tasklist_prompt,
        {
            tasklist_body,
            widget = wibox.container.background,
        },
        layout = wibox.layout.fixed.vertical,
    }

    return google_tasks
end

return setmetatable(google_tasks, {__call = function(_, ...) return new(...) end})
