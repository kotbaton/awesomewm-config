local awful     = require("awful")
local tagnames  = require("modules.tools.tagnames")

create_client_menu = function(c)
    local tags = awful.screen.focused().tags
    local names = tagnames.read(c.screen.index)
    local task_menu = {
        {
            "× Close",  function() c:kill() end
        },
        {
            "    Move to tag",
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
            "    Add to tag",
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
        { "+ Toogle maximize", function() c.maximized = not c.maximized end },
        { "↓ Toogle minimize", function() c.minimized = not c.minimized end },
        { "✈ Toogle floating", function() c.floating = not c.floating end },
        { "^ Toggle on top",   function() c.ontop = not c.ontop end },
        { "▪ Toggle sticky",   function() c.sticky = not c.sticky end },
        { "  Nevermind",       function() end },
    }
    
    return awful.menu(task_menu)
end

return create_client_menu
