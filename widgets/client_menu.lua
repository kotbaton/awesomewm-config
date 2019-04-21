local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir().. "theme_without_borders/theme.lua")

local main_menu = require("widgets.main_menu")

local tagnames = require("tag-names")

local client_menu = {}

client_menu.button = wibox.widget{
    text = '≡',
    align  = 'center',
    valign = 'center',
    forced_width = 24,
    widget = wibox.widget.textbox
}

client_menu.menu = function(c)
    local tags = awful.screen.focused().tags
    local names = tagnames.read()
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

client_menu.button:buttons(gears.table.join(
        awful.button({ }, 1, function ()
            c = client.focus
            main_menu()
        end),
        awful.button({ }, 2, function ()
            main_menu()
        end),
        awful.button({ }, 3, function ()
            c = client.focus
            if c == nil then
                main_menu()
                return
            end
            client_menu.menu(c):toggle()
        end)
    )
)

return client_menu
