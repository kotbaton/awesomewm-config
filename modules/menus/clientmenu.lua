local awful     = require("awful")
local beautiful = require("beautiful")
local tagnames  = require("modules.tools.tagnames")

local function create_client_menu(c)
    local tags = awful.screen.focused().tags
    local names = tagnames.read(c.screen)
    local task_menu = {
        {
            "Move to tag",
            {
                {names[1], function() c:move_to_tag(tags[1]) end},
                {names[2], function() c:move_to_tag(tags[2]) end},
                {names[3], function() c:move_to_tag(tags[3]) end},
                {names[4], function() c:move_to_tag(tags[4]) end},
                {names[5], function() c:move_to_tag(tags[5]) end},
                {names[6], function() c:move_to_tag(tags[6]) end},
                {names[7], function() c:move_to_tag(tags[7]) end},
                {names[8], function() c:move_to_tag(tags[8]) end},
                {names[9], function() c:move_to_tag(tags[9]) end},
            }
        },
        {
            "Add to tag",
            {
                {names[1], function() c:toggle_tag(tags[1]) end},
                {names[2], function() c:toggle_tag(tags[2]) end},
                {names[3], function() c:toggle_tag(tags[3]) end},
                {names[4], function() c:toggle_tag(tags[4]) end},
                {names[5], function() c:toggle_tag(tags[5]) end},
                {names[6], function() c:toggle_tag(tags[6]) end},
                {names[7], function() c:toggle_tag(tags[7]) end},
                {names[8], function() c:toggle_tag(tags[8]) end},
                {names[9], function() c:toggle_tag(tags[9]) end},
            }
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
