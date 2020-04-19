local awful     = require("awful")
local beautiful = require("beautiful")
local tagnames  = require("modules.tools.tagnames")

local function create_client_menu(c)
    local tags = awful.screen.focused().tags
    local names = tagnames.read(c.screen)

    local move_to_tag = {}
    local add_to_tag = {}

    for i = 1, #tags do
        table.insert(move_to_tag, {names[i], function() c:move_to_tag(tags[i]) end})
        table.insert(add_to_tag, {names[i], function() c:toggle_tag(tags[i]) end})
    end

    local task_menu = {
        {
            "Move to tag",
            move_to_tag
        },
        {
            "Add to tag",
            add_to_tag
        },
        { "Maximize", function() c.maximized = not c.maximized end, beautiful.titlebar_maximized_button_focus_inactive },
        { "Minimize", function() c.minimized = not c.minimized end, beautiful.titlebar_minimize_button_focus },
        { "Floating", function() c.floating = not c.floating end, beautiful.titlebar_floating_button_focus_inactive },
        { "On top",   function() c.ontop = not c.ontop end, beautiful.titlebar_ontop_button_focus_inactive },
        { "Sticky",   function() c.sticky = not c.sticky end, beautiful.titlebar_sticky_button_focus_inactive },
        { "Close",  function() c:kill() end, beautiful.titlebar_close_button_focus },
    }
    
    return awful.menu(task_menu)
end

local current = {
    menu = nil,
    client = nil
}

local function toggle_menu(c)
    if c ~= current.client then
        if current.menu then
            current.menu:hide()
        end
        current.menu = create_client_menu(c)
        current.client = c
    end
    current.menu:toggle()
end

return toggle_menu
