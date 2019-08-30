local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup").widget 

local lock_command = require("settings").lock_command
local apps = require("settings").default_apps

beautiful.init(gears.filesystem.get_configuration_dir() .. "gruvbox-theme/theme.lua")

local menu = {
    { "Hotkeys", function() return false, hotkeys_popup.show_help end, beautiful.hotkeys_icon},
    { "Restart", awesome.restart, beautiful.reboot_icon},
    { "Quit", function() awesome.quit() end, beautiful.logout_icon}
}

local powermenu = {
    { "Lock", function() awful.spawn(lock_command) end, beautiful.lock_icon},
    { "Reboot", function() awful.spawn("reboot") end, beautiful.reboot_icon},
    { "Shutdown", function() awful.spawn("shutdown now") end, beautiful.shutdown_icon}
}

local appmenu = require("modules.tools.menu")
local mainmenu = awful.menu({ items = {
            { "Applications", appmenu.build({icon_size = 24 }), nil },
            { "Awesome", menu, beautiful.awesome_icon},
            { "Computer", powermenu, beautiful.shutdown_icon},
            { "Terminal", function() awful.spawn(apps.terminal, false) end, beautiful.terminal_icon},
            { "Browser", function()  awful.spawn(apps.browser, false) end, beautiful.chrome_icon },
            { "Files", function() awful.spawn(apps.file_manager, false) end, beautiful.thunar_icon },
            { "Music", function() awful.spawn(apps.music_player, false) end, beautiful.music_icon },
            { "Telegram", function() awful.spawn(apps.telegram, false) end, beautiful.telegram_icon },
        }
    })

return mainmenu
