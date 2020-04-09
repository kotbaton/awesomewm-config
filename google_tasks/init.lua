local awful             = require('awful')
local gears             = require('gears')
local wibox             = require('wibox')
local beautiful         = require('beautiful')
local naughty           = require('naughty')
local dpi               = require('beautiful.xresources').apply_dpi

local cjson             = require('cjson')

local list_item         = require('google_tasks.list_item')
local helpers           = require('google_tasks.helpers')

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


--[[
-- Tasklist representation:
-- https://developers.google.com/tasks/v1/reference/tasklists#resource
-- {
--   "kind": "tasks#taskList",
--   "id": string,
--   "etag": etag,
--   "title": string,
--   "updated": datetime,
--   "selfLink": string
-- }
--]]

--[[
-- Task representation:
-- https://developers.google.com/tasks/v1/reference/tasks
-- {
--   "kind": "tasks#task",
--   "id": string,
--   "etag": etag,
--   "title": string,
--   "updated": datetime,
--   "selfLink": string,
--   "parent": string,
--   "position": string,
--   "notes": string,
--   "status": string,
--   "due": datetime,
--   "completed": datetime,
--   "deleted": boolean,
--   "hidden": boolean,
--   "links": [
--     {
--       "type": string,
--       "description": string,
--       "link": string
--     }
--   ]
-- }
--]]


--[[
-- Here's short explanation of how this things work:
--
-- gears.timer(every 300s == 5min) -- Periodically start updates
--  V
-- get_all_tasklists() -- Updates tasklists info and save it in cache table
--  V
-- get_list() -- Called for every tasklist
--  V
-- emit_signal('tasks::ready', tasklist) -- When tasklist downloaded
--  V
-- update_widget() -- Called when signal 'tasks::ready' is emitted.
--                    Fills widget with tasks
--
--
-- update_tasklist_menu() -- When clicked on tasklist title, but there's
--  V                        no menu in cache
-- update_widget() -- Reset widget and fill it with tasks
--                    from choosed tasklist
--
--
-- -Task adding- -- Anonymous callback for left mouse click
--  V               on add_task_button
-- Send new task to cloud
--  V
-- Insert returned task to cached tasklist
--  V
-- update_widget()
--
--
-- -Task editing- -- Callback to 'tasks::edit' signal
--  V
-- Send updated task to cloud
--  V
-- Update task's fields in cached tasklist
--  V
-- update_widget()
--]]

local cache = {
    -- 'Array' with tasklists tables
    tasklists = nil,

    -- Ref to current tasklist table
    current_tasklist = nil,

    -- Cahced version of tasklist choose menu
    -- (So we don't need rebuid it every time)
    tasklist_choose_menu = nil,

    -- Cached lists with tasks
    -- key: tasklist_id:     tasklist_id
    -- value: array with task representation tables
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

local sort_function = {
    current = nil,
    position = function(a, b)
        return a.position < b.position
    end,
    due_time = function(a, b)
        if a.due ~= nil and b.due ~= nil then
            return a.due < b.due
        elseif a.due == nil and b.due ~= nil then
            return false
        elseif a.due ~= nil and b.due == nil then
            return true
        else
            return a.position < b.position
        end
    end,
}
sort_function.current = sort_function.position


local function new(args)
    local add_task_button = wibox.widget {
        text   = ' ',
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
        text   = ' ',
        align  = 'center',
        valign = 'center',
        font   = 'Hermit Bold 15', -- TODO
        widget = wibox.widget.textbox
    }

    local sort_order_button = wibox.widget {
        text   = '  ',
        align  = 'center',
        valign = 'center',
        font   = 'Hermit Bold 18', -- TODO
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
        table.sort(items, sort_function.current)

        tasklist_title:set_text(tasklist.title)
        tasklist_body:reset()
        if next(items) ~= nil then -- Check if table is not empty
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
        for i, tasklist in ipairs(cache.tasklists) do
            menu_entries[i] = {
                tasklist.title,
                function()
                    if cache.current_tasklist == tasklist then
                        return
                    end
                    cache.current_tasklist = tasklist
                    update_widget(cache.current_tasklist,
                                  cache.lists[cache.current_tasklist.id])
                end
            }
        end
        cache.tasklist_choose_menu = awful.menu(menu_entries)
    end

    local sort_order_menu = awful.menu({
            {
                'Sort by position',
                function() 
                    sort_function.current = sort_function.position 
                    update_widget(cache.current_tasklist,
                        cache.lists[cache.current_tasklist.id])
                end,
            },
            {
                'Sort by date',
                function() 
                    sort_function.current = sort_function.due_time 
                    update_widget(cache.current_tasklist,
                        cache.lists[cache.current_tasklist.id])
                end,
            }
    })

    local function get_list(tasklist)
        -- Get tasks from tasklist and save it into cache
        local command = base_command .. ' --list ' .. tasklist.id
        awful.spawn.easy_async(command, function(stdout, stderr)
            if stdout == '' then
                -- Looks like that tasklist is empty
                -- Put empty table into cache.
                -- so we can insert tasks here later
                cache.lists[tasklist.id] = {}
                awesome.emit_signal('tasks::ready', tasklist)
                return
            end
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
                cache.current_tasklist = cache.tasklists[1]
            end

            for i, tasklist in ipairs(cache.tasklists) do
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

    sort_order_button:buttons(awful.button({}, 1, function()
        sort_order_menu:toggle()
    end))

    tasklist_sync_button:buttons(awful.button({}, 1, function()
        tasklist_title:set_text('Updating...')
        get_all_tasklists()
        update_tasklist_menu()
    end))

    add_task_button:buttons(awful.button({}, 1, function()
        awful.prompt.run {
            prompt      = 'Add: ',
            font        = 'Hermit 11', -- TODO
            textbox     = tasklist_prompt.widget,
            bg_cursor   = beautiful.colors.purple,
            fg_cursor   = beautiful.colors.purple,
            highlighter = helpers.highlighter,
            exe_callback = function(text)
                if text == '' or text == nil then
                    return
                end
                tasklist_title:set_text('Adding...')
                -- Save in case of changing current tasklist until we save task
                local cur_tasklist_id = cache.current_tasklist.id

                local title, notes, due = helpers.split_text(text)

                -- TODO: rewrite with using string.format
                local command = base_command .. ' --insert '
                                .. cur_tasklist_id .. ' "'
                                .. title .. '" "'
                                .. notes .. '" "'
                                .. due .. '"'
                awful.spawn.easy_async(command, function(stdout, stderr)
                    if stdout == '' or stdout == nil then
                        raise_error_notification()
                        return
                    end
                    local new_task = cjson.decode(stdout)
                    table.insert(cache.lists[cur_tasklist_id], 1, new_task)
                    if cache.current_tasklist.id == cur_tasklist_id then
                        update_widget(cache.current_tasklist,
                                      cache.lists[cache.current_tasklist.id])
                    end
                end)
            end
        }
    end))

    awesome.connect_signal('tasks::update_needed', function()
        tasklist_title:set_text('Updating...')
        get_list(cache.current_tasklist)
    end)

    awesome.connect_signal('tasks::ready', function(tasklist)
        if tasklist.id == cache.current_tasklist.id then
            update_widget(tasklist,
                          cache.lists[tasklist.id])
        end
    end)

    awesome.connect_signal('tasks::edit', function(tasklist, task)
        local text = task.title
        if task.notes ~= nil and task.notes ~= '' then
            text = text .. '//' .. task.notes
        end

        if task.due ~= nil and task.due ~= '' then
            local y, m, d = task.due:match('(%d+)-(%d+)-(%d+)')
            text = text .. string.format(' [%02d.%02d.%04d]', d, m, y)
        end

        awful.prompt.run {
            prompt      = 'Edit: ',
            text        = text,
            font        = 'Hermit 11', -- TODO
            textbox     = tasklist_prompt.widget,
            bg_cursor   = beautiful.colors.purple,
            fg_cursor   = beautiful.colors.purple,
            highlighter = helpers.highlighter,
            exe_callback = function(text)
                if text == '' or text == nil then
                    return
                end
                tasklist_title:set_text('Editing...')
                -- Save in case of changing current tasklist until we save task
                local cur_tasklist_id = cache.current_tasklist.id

                local title, notes, due = helpers.split_text(text)

                -- TODO: rewrite with using string.format
                local command = base_command .. ' --edit '
                                .. cur_tasklist_id .. ' '
                                .. task.id .. ' "'
                                .. title .. '" "'
                                .. notes .. '" "'
                                .. due .. '"'

                awful.spawn.easy_async(command, function(stdout, stderr)
                    if stdout == '' or stdout == nil then
                        raise_error_notification()
                        return
                    end
                    local edited_task = cjson.decode(stdout)
                    for _, task in ipairs(cache.lists[cur_tasklist_id]) do
                        if task.id == edited_task.id then
                            task.title = edited_task.title
                            task.notes = edited_task.notes
                            task.due = edited_task.due
                            break
                        end
                    end
                    if cache.current_tasklist.id == cur_tasklist_id then
                        update_widget(cache.current_tasklist,
                                      cache.lists[cache.current_tasklist.id])
                    end
                end)
            end
        }
    end)

    tasklist_body:buttons(
        gears.table.join(
            awful.button({}, 4, function()
                local cur_items = cache.lists[cache.current_tasklist.id]

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
                local cur_items = cache.lists[cache.current_tasklist.id]

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

    local timer = gears.timer {
        timeout   = 300,
        autostart = true,
        call_now  = true,
        callback  = function()
            get_all_tasklists()
        end
    }

    -- Actually a widget
    google_tasks = {
        {
            button_decorator(add_task_button),
            button_decorator(tasklist_title),
            {
                button_decorator(sort_order_button),
                button_decorator(tasklist_sync_button),
                layout = wibox.layout.fixed.horizontal
            },
            forced_height = dpi(30),
            layout = wibox.layout.align.horizontal
        },
        tasklist_prompt,
        {
            tasklist_body,
            widget = wibox.container.background,
        },
        spacing = dpi(8),
        layout = wibox.layout.fixed.vertical,
    }

    return google_tasks
end

return setmetatable(google_tasks, {__call = function(_, ...) return new(...) end})
