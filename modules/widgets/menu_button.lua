local awful         = require("awful")
local gears         = require("gears")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir().. "theme_without_borders/theme.lua")

local mainmenu      = require("modules.menus.mainmenu")
local clientmenu    = require("modules.menus.clientmenu")
local tagnames      = require("modules.tools.tagnames")

local menu_button = {}

menu_button = wibox.widget{
    text = '≡',
    align  = 'center',
    valign = 'center',
    forced_width = 24,
    widget = wibox.widget.textbox
}

menu_button:buttons(gears.table.join(
        awful.button({ }, 1, function ()
            c = client.focus
            mainmenu()
        end),
        awful.button({ }, 2, function ()
            mainmenu()
        end),
        awful.button({ }, 3, function ()
            c = client.focus
            if c == nil then
                mainmenu()
                return
            end
            clientmenu(c):toggle()
        end)
    )
)

return menu_button
