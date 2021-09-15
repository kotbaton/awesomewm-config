local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require('menubar')

local settings = require('settings')
local launcher = settings.launcher
local lock_command = settings.lock_command
local apps = settings.default_apps

beautiful.init(gears.filesystem.get_configuration_dir() .. "gruvbox-theme/theme.lua")

ignore = {
    'Hibernate',
    'Logout',
    'Reboot',
    'Shutdown',
    'Lock Screen',
    'Suspend'
}

local menu = {
    { "Hotkeys", function() return false, hotkeys_popup.widget.show_help end, beautiful.hotkeys_icon},
    { "Restart", awesome.restart, beautiful.reboot_icon},
    { "Quit", function() awesome.quit() end, beautiful.logout_icon}
}

local powermenu = {
    { "Lock", function() awful.spawn(lock_command) end, beautiful.lock_icon},
    { "Reboot", function() awful.spawn("reboot") end, beautiful.reboot_icon},
    { "Shutdown", function() awful.spawn("shutdown now") end, beautiful.shutdown_icon}
}

local appmenu = require("modules.tools.menu")

local menu_items = {
    {"Applications", appmenu.build({icon_size = 24, skip_items=ignore}), nil},
    {"Awesome", menu, beautiful.awesome_icon},
    {"Computer", powermenu, beautiful.shutdown_icon},
    {
        "Terminal",
        function() awful.spawn(apps.terminal, false) end,
        menubar.utils.lookup_icon('terminal')
    }
}

for _, app in ipairs(launcher) do
    table.insert(menu_items, {
            app,
            function() awful.spawn(app, false) end,
            menubar.utils.lookup_icon(app)
        })
end

local mainmenu = awful.menu({items = menu_items})

return mainmenu
