local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup").widget 

beautiful.init(gears.filesystem.get_configuration_dir() .. "gruvbox-theme/theme.lua")

local menu = {
    { "Hotkeys", function() return false, hotkeys_popup.show_help end, beautiful.hotkeys_icon},
    { "Restart", awesome.restart, beautiful.reboot_icon},
    { "Quit", function() awesome.quit() end, beautiful.logout_icon}
}

local powermenu = {
    { "Lock", function() awful.spawn("light-locker-command --lock") end, beautiful.lock_icon},
    { "Reboot", function() awful.spawn("reboot") end, beautiful.reboot_icon},
    { "Shutdown", function() awful.spawn("shutdown now") end, beautiful.shutdown_icon}
}

local appmenu = require("modules.tools.menu")
local mainmenu = awful.menu({ items = {
            { "Applications", appmenu.build({icon_size = 24 }), nil },
            { "Awesome", menu, beautiful.awesome_icon},
            { "Computer", powermenu, beautiful.shutdown_icon},
            { "Terminal", function() awful.spawn("kitty", false) end, beautiful.terminal_icon},
            { "Browser", function()  awful.spawn("google-chrome-stable", false) end, beautiful.chrome_icon },
            { "Files", function() awful.spawn("pcmanfm", false) end, beautiful.thunar_icon },
            { "Music", function() awful.spawn("spotify", false) end, beautiful.music_icon },
            { "Telegram", function() awful.spawn("telegram-desktop", false) end, beautiful.telegram_icon },
        }
    })

return function() mainmenu:toggle() end
