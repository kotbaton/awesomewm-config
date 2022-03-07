local gears             = require("gears")
local awful             = require("awful")
local wibox             = require("wibox")
local beautiful         = require("beautiful")
local naughty           = require("naughty")
local hotkeys_popup     = require("awful.hotkeys_popup").widget

require("awful.autofocus")
require("awful.remote")

local modules           = require("modules")
local settings          = require("settings")
local dpi               = require("beautiful.xresources").apply_dpi

-- Set default apps
local terminal = settings.default_apps.terminal

-- Start autostart application
for _, app in ipairs(settings.autostart) do
    awful.spawn.once(app)
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)
-- }}}

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true
        naughty.notify({ preset = naughty.config.presets.critical,
                title = "Oops, an error happened!",
            text = tostring(err) })
        in_error = false
    end)
end

-- Notification configuration
naughty.config.defaults.border_width = dpi(0)
naughty.config.spacing = dpi(8)
naughty.config.padding = dpi(8)
naughty.config.defaults.margin = dpi(8)
naughty.config.defaults.timeout = 5

-- Theme init
beautiful.init(gears.filesystem.get_configuration_dir() .. "gruvbox-theme/theme.lua")

-- Default modkey.
local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        -- awful.layout.suit.tile.top,
        -- awful.layout.suit.fair,
        -- awful.layout.suit.fair.horizontal,
        -- awful.layout.suit.spiral,
        -- awful.layout.suit.spiral.dwindle,
        -- awful.layout.suit.max,
        -- awful.layout.suit.max.fullscreen,
        -- awful.layout.suit.magnifier,
        -- awful.layout.suit.corner.nw,
        -- awful.layout.suit.corner.ne,
        -- awful.layout.suit.corner.sw,
        -- awful.layout.suit.corner.se,
    })
end)

local function set_wallpaper(s)
    awful.spawn.with_shell("~/.fehbg", false)
end
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local mytextclock = wibox.widget.textclock("%R")
mytextclock:buttons(gears.table.join(awful.button({},1, function()
    modules.sidebar.toggle()
end)))

local mykeyboardlayout = awful.widget.keyboardlayout()
local mypromptbox = awful.widget.prompt()
local myseparator = wibox.widget.textbox(" ")
local nextEmptyTag = wibox.widget {
    markup = "<b>+</b>",
    align = "center",
    forced_width = dpi(16),
    widget = wibox.widget.textbox
}

nextEmptyTag:buttons(gears.table.join(awful.button({},1, function()
    awful.tag.viewnone()
    local tgs = awful.screen.focused().tags
    for i = 1, #tgs do
        if #tgs[i]:clients() == 0 then
            awful.tag.viewtoggle(tgs[i])
            break
        end
    end
end)))

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    local tags = modules.tools.tagnames.read(s)
    awful.tag(tags, s, awful.layout.layouts[2])
    -- Buttons for taglist and taglist widget
    local taglist_buttons = gears.table.join(
        awful.button({ }, 1,        function(t) t:view_only() end),
        awful.button({ modkey }, 1, function(t)
           if client.focus then
                client.focus:move_to_tag(t)
            end
        end),
        awful.button({ }, 2),
        awful.button({ }, 3,        awful.tag.viewtoggle),
        awful.button({ modkey }, 3, function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
        end),
        awful.button({ }, 4,        function(t) awful.tag.viewnext(t.screen) end),
        awful.button({ }, 5,        function(t) awful.tag.viewprev(t.screen) end)
    )
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.noempty, taglist_buttons)

    -- Layoutbox widget and buttons
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 2, function () awful.tag.togglemfpol(t) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    local tasklist_buttons = gears.table.join(
        awful.button({ }, 1,
            function (c)
                if c == client.focus then
                    c.minimized = true
                else
                    c.minimized = false
                    if not c:isvisible() and c.first_tag then
                        c.first_tag:view_only()
                    end
                    client.focus = c
                    c:raise()
                end
            end),
        awful.button({ }, 2,
            function(c)
                -- c:kill()
            end),
        awful.button({ }, 3,
            function(c)
                modules.menus.clientmenu(c)
            end),
        awful.button({ }, 4,
            function ()
                awful.client.focus.byidx(1)
            end),
        awful.button({ }, 5,
            function ()
                awful.client.focus.byidx(-1)
            end)
    )

    s.mytasklist = awful.widget.tasklist {
        screen          = s,
        filter          = awful.widget.tasklist.filter.currenttags,
        buttons         = tasklist_buttons,
        update_function = list_update,
        layout          = {
            spacing = beautiful.tasklist_spacing or dpi(8),
            layout = wibox.layout.flex.horizontal,
        },
        widget_template = {
            {
                id     = 'text_role',
                align  = 'center',
                widget = wibox.widget.textbox,
            },
            id     = 'background_role',
            widget = wibox.container.background,
        },
    }
    s.mytasklist:set_max_widget_size(dpi(200))

    s.wibar = awful.wibar({
            position = "top",
            screen = s,
            height = dpi(24),
            ontop = false,
            bg = beautiful.colors.black .. 'DD',
        }):setup {
        {
            -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            modules.widgets.menu_button,
            mypromptbox,
            s.mylayoutbox,
            s.mytaglist,
            nextEmptyTag,
        },
        {
            -- Center widgets
            layout = wibox.layout.align.horizontal,
            myseparator,
            s.mytasklist,
            myseparator,
        },
        {
            -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            modules.widgets.pomodoro.widget,
            myseparator,
            modules.widgets.player.widget,
            myseparator,
            modules.widgets.battery.widget,
            modules.widgets.volume.text_widget,
            mykeyboardlayout,
            mytextclock,
            modules.widgets.tray.widget,
            layout = wibox.layout.fixed.horizontal,
        },
        layout = wibox.layout.align.horizontal,
    }
end)

-- Set keys
local globalkeys = gears.table.join(
    awful.key({ modkey,           }, "Return",
        function ()
            awful.spawn(terminal)
        end, {description = "open a terminal", group = "Applications"}),

    awful.key({ modkey, "Shift" }, "Return",
        function ()
            awful.spawn(terminal, { floating = true })
        end, {description = "open a floating terminal", group = "Applications"}),

    awful.key({"Control", "Mod1"}, "w",
        function()
            script = gears.filesystem.get_configuration_dir() .. 'scripts/trans_clip.sh'
            awful.spawn.with_shell(script)
        end, {description = "Translate text from selection", group = "Translation"}),

    awful.key({"Control", "Mod1"}, "e",
        function()
            awful.prompt.run {
                prompt       = "Text for translation: ",
                textbox      = mypromptbox.widget,
                exe_callback = function(text)
                    awful.spawn.easy_async([[
                            bash -c 'trans -tl ru -brief "]] .. text .. [["'
                    ]], function(stdout)
                    naughty.notify({
                        title      = "Translation:",
                        text       = stdout,
                        timeout    = 0,
                        max_height = dpi(400),
                        })
                    end)
                end
            }
        end, {description = "Translate text", group = "Translation"}),

    awful.key({"Control", "Mod1"}, "c",
        function()
            local python_cmd = [[
            ipython -i -c "import numpy as np
from platform import python_version
print(f'Hello in Python {python_version()} 🐍\nNumpy is imported already.\n')"
            ]]
--            local python_cmd = [[
--            python -i -c "import numpy as np
--from platform import python_version
--print(f'Hello in Python {python_version()} 🐍\nNumpy is imported already.')"
--            ]]
            awful.spawn.spawn("kitty -e " .. python_cmd, {
                    floating = true,
                })
        end, {description = "Python", group = "Applications"}),

    ----------------------{ AWESOME }--------------------------------------------
    awful.key({ modkey }, "r",
        function ()
            awful.spawn([[rofi -show drun -modi drun -show-icons -width 30 -lines 8 -kb-row-tab "Tab"]])
        end, {description = "Run rofi launcher", group = "Awesome"}),

    awful.key({ modkey, "Shift" }, "r",
        function ()
            mypromptbox:run()
        end, {description = "Run prompt", group = "Awesome"}),

    awful.key({"Control", "Mod1"}, "l",
        function()
            awful.spawn(settings.lock_command)
        end, {description = "Lock", group = "Awesome"}),

    awful.key({ modkey, "Control" }, "r", awesome.restart, {description = "Reload awesome", group = "Awesome"}),

    --awful.key({ modkey, "Shift"   }, "q", awesome.quit, {description = "Quit awesome", group = "Awesome"}),

    awful.key({ modkey,           }, "space",
        mykeyboardlayout.next_layout,
        {description="Change language", group="Awesome"}),

    awful.key({ modkey, "Shift"   }, "a", hotkeys_popup.show_help, {description="Show help", group="Awesome"}),

    awful.key({modkey}, "c", function()
        modules.sidebar.toggle()
    end, {description = "Open system info popup", group = "Awesome"}),

    awful.key({ modkey,           }, "x",
        function ()
            awful.prompt.run{
                prompt       = "Run Lua code: ",
                textbox      = mypromptbox.widget,
                exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"}
        end, {description = "Lua execute prompt", group = "Awesome"}),

    awful.key({ modkey,           }, "a",
        function ()
            modules.menus.mainmenu:toggle()
        end, {description = "Show main menu", group = "Awesome"}),

    awful.key({ modkey,           }, "q",
        function ()
            modules.widgets.tray.toggle()
        end, {description = "Show system tray", group = "Awesome"}),

    awful.key({ modkey, "Shift" }, "p",
        function ()
            modules.widgets.pomodoro.toggle()
        end, {description = "Show/hide pomodoro timer", group = "Awesome"}),

    awful.key({ modkey,           }, "b",
        function ()
            modules.widgets.battery.show_status()
        end, {description = "Show battery status", group = "Awesome"}),

    awful.key({ modkey, "Control", "Shift" }, "t",
        function ()
            for _, c in ipairs(client.get()) do
                awful.titlebar.toggle(c)
            end
        end,
        {description = "Toggle titlebar of all windows", group = "Clients management"}),

    ----------------------{ SOUND }--------------------------------------------
    awful.key({ }, "XF86AudioRaiseVolume",
        function()
            modules.widgets.volume.control("increase", 2)
        end, {description="Increase volume by 2", group="Volume control"}),

    awful.key({ "Shift" }, "XF86AudioRaiseVolume",
        function()
            modules.widgets.volume.control("increase", 10)
        end, {description="Increase volume by 10", group="Volume control"}),

    awful.key({ }, "XF86AudioLowerVolume",
        function()
            modules.widgets.volume.control("decrease")
        end, {description="Decrease volume by 2", group="Volume control"}),

    awful.key({ "Shift" }, "XF86AudioLowerVolume",
        function()
            modules.widgets.volume.control("decrease", 10)
        end, {description="Decrease volume by 10", group="Volume control"}),

    awful.key({ }, "XF86AudioMute",
        function()
            modules.widgets.volume.control("toggle")
        end, {description="Mute/Unmute volume", group="Volume control"}),

    awful.key({ }, "XF86AudioMicMute",
        function()
            command = [[pactl list sources | grep -oP "Name: \S+" | grep "input" | cut -d' ' -f2 | xargs -I{} pactl set-source-mute {} toggle]]
            awful.spawn.with_shell(command)
        end, {description="Toggle mute on all microphones", group="Volume control"}),

    awful.key({ "Shift" }, "XF86AudioMicMute",
        function()
            command = [[pactl list sources | grep -oP "Name: \S+" | grep "input" | cut -d' ' -f2 | xargs -I{} pactl set-source-mute {} false]]
            awful.spawn.with_shell(command)
        end, {description="Unmute all microphones", group="Volume control"}),

    --------------------------{ BRIGHTNESS }----------------------------------
    awful.key({ }, "XF86MonBrightnessUp",
        function()
            awful.spawn("bash -c 'xbacklight -inc 10'", false)
        end, {description="Increase screen brightness", group="Brightness control"}),

    awful.key({ }, "XF86MonBrightnessDown",
        function()
            awful.spawn("bash -c 'xbacklight -dec 10'", false)
        end, {description="Decrease screen brightness", group="Brightness control"}),

    awful.key({ "Shift" }, "XF86MonBrightnessUp",
        function()
            awful.spawn("bash -c 'xbacklight -set 100'", false)
        end, {description="Set screen brightness on 100", group="Brightness control"}),

    awful.key({ "Shift" }, "XF86MonBrightnessDown",
        function()
            awful.spawn("bash -c 'xbacklight -set 0.1'", false)
        end, {description="Set screen brightness on 0", group="Brightness control"}),

    ----------------------{ PRINTSCREEN }--------------------------------------------

    awful.key({ "Ctrl" }, "Print", nil,
        function()
            awful.util.spawn(gears.filesystem.get_configuration_dir() .. "scripts/screenshot.sh", false)
        end, { description = "Make screenshot of fullscreen", group = "Screenshot" }),

    awful.key({ "Shift" }, "Print", nil,
        function()
            awful.util.spawn(gears.filesystem.get_configuration_dir() .. "scripts/screenshot.sh -s", false)
        end, { description = "Make screenshot of selected area", group = "Screenshot" }),

    ----------------------{ PLAYER }--------------------------------------------

    awful.key({ modkey }, "XF86AudioMute",
        function()
            modules.widgets.player.control.toggle()
        end, {description="Toggle Pause", group="Music player control"}),

    awful.key({ modkey }, "XF86AudioLowerVolume",
        function()
            modules.widgets.player.control.prev()
        end, {description="Previous track", group="Music player control"}),

    awful.key({ modkey }, "XF86AudioRaiseVolume",
        function()
            modules.widgets.player.control.next()
        end, {description="Next track", group="Music player control"}),

    ----------------------{ TAGS }--------------------------------------------
    awful.key({ modkey,}, "p", function() awful.tag.togglemfpol(t) end, {description = "Toggle master fill police", group = "Tag management"}),

    awful.key({ modkey,}, "`",     awful.tag.history.restore, {description = "Go to previous tag", group = "Tag management"}),

    awful.key({ modkey,}, "-", function() awful.tag.setgap(awful.tag.getgap(t) - 5) end, {description = "Decrease gaps", group = "Tag management"}),

    awful.key({ modkey,}, "=", function() awful.tag.setgap(awful.tag.getgap(t) + 5) end, {description = "Increase gaps", group = "Tag management"}),

    awful.key({ modkey,}, "0", function() awful.tag.setgap(0) end, {description = "Set zero gaps", group = "Tag management"}),

    awful.key({ modkey,}, "i",
        function()
            awful.prompt.run {
                prompt       = "Rename tag: ",
                textbox      = mypromptbox.widget,
                exe_callback = function(new_name)
                    local t = awful.screen.focused().selected_tag -- Get current tag
                    if t then -- If success, check does we got text or no
                        if not new_name or #new_name == 0 then -- If length of input text 0 set default tag name
                            t.name = t.index
                        else
                            t.name = t.index .. ":" .. new_name
                        end
                    end
                    -- Write tagnames in cache file
                    local scr = awful.screen.focused()
                    modules.tools.tagnames.write(scr, scr.tags) end
            }
        end, {description = "Rename active tag", group = "Tag management"}),

    awful.key({ modkey,           }, "l",
        function ()
            awful.tag.incmwfact( 0.05)
        end, {description = "Increase master width factor", group = "Tag management"}),

    awful.key({ modkey,           }, "h",
        function ()
            awful.tag.incmwfact(-0.05)
        end, {description = "Decrease master width factor", group = "Tag management"}),

    awful.key({ modkey, "Shift"   }, "l",
        function ()
            awful.tag.incnmaster( 1, nil, true)
        end, {description = "Increase the number of master clients", group = "Tag management"}),

    awful.key({ modkey, "Shift"   }, "h",
        function ()
            awful.tag.incnmaster(-1, nil, true)
        end, {description = "Decrease the number of master clients", group = "Tag management"}),

    awful.key({ modkey, "Control" }, "l",
        function ()
            awful.tag.incncol( 1, nil, true)
        end, {description = "Increase the number of columns", group = "Tag management"}),

    awful.key({ modkey, "Control" }, "h",
        function ()
            awful.tag.incncol(-1, nil, true)
        end, {description = "Decrease the number of columns", group = "Tag management"}),

    awful.key({ "Mod1",           }, "space",
        function ()
            awful.layout.inc( 1)
        end, {description = "Select next tag layout", group = "Tag management"}),

    awful.key({ "Mod1",           }, "j",
        function ()
            local scr = awful.screen.focused()
            for i = 1, #scr.tags do
                awful.tag.viewnext()
                if #scr.selected_tag:clients() ~= 0 then
                    break
                end
            end
        end, {description = "View next not-empty tag", group = "Tag management"}),

    awful.key({ "Mod1",           }, "k",
        function ()
            local scr = awful.screen.focused()
            for i = 1, #scr.tags do
                awful.tag.viewprev()
                if #scr.selected_tag:clients() ~= 0 then
                    break
                end
            end
        end, {description = "View prev not-empty tag", group = "Tag management"}),

    awful.key({ "Mod1", "Shift"   }, "space",
        function ()
            awful.layout.inc(-1)
        end, {description = "Select previous tag layout", group = "Tag management"}),

    ----------------------{ WINDOWS CONTROL }--------------------------------------------
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
        end, {description = "Focus next by index", group = "Clients management"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end, {description = "Focus next by index", group = "Clients management"}),

    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end, {description = "Focus previous by index", group = "Clients management"}),

    awful.key({ modkey, "Shift"   }, "j",
        function ()
            awful.client.swap.byidx(  1)
        end, {description = "Swap with next client by index", group = "Clients management"}),

    awful.key({ modkey, "Shift"   }, "k",
        function ()
            awful.client.swap.byidx( -1)
        end, {description = "Swap with previous client by index", group = "Clients management"}),

    awful.key({ modkey, }, "o",
        function ()
            awful.screen.focus_relative(1)
        end, {description = "Focus the next screen", group = "Screens management"}),

    awful.key({ modkey, "Shift"}, "o",
        function ()
            local c = client.focus
            if c then c:move_to_screen() end
        end, {description = "Move focused window on next screen", group = "Screens management"}),

    awful.key({ modkey, }, "F7",
        function ()
            awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "scripts/monitor_toggle.sh " .. settings.monitors.internal .. " " .. settings.monitors.external)
        end, {description = "Toggle monitors script", group = "Screens management"}),

    awful.key({ modkey,           }, "u",
        function()
            awful.client.urgent.jumpto()
        end, {description = "Jump to urgent client", group = "Clients management"}),

    awful.key({ modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end, {description = "Restore minimized", group = "Clients management"})
)

for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "View tag", group = "Tag management"}),

        -- Toggle tag display.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {descriptiond = "Toggle tag", group = "Tag management"}),

        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "Move client to tag", group = "Tag management"}),

        -- Toggle tag on focused client.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            {description = "Add client to tag", group = "Tag management"}))

end

for i = 1,#settings.launcher do
    globalkeys = gears.table.join(globalkeys,
        -- Add launcher hotkey for this button
        awful.key({modkey}, 'F' .. i,
            function() awful.spawn(settings.launcher[i]) end,
        {description=settings.launcher[i], group="Applications"}))
end

root.keys(globalkeys)
-- Set buttons
local rootbuttons = gears.table.join(
    awful.button({ }, 3,
        function ()
            modules.menus.mainmenu:toggle()
        end)
    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
)

root.buttons(rootbuttons)

-- Create table with client buttons
local clientbuttons = gears.table.join(
    awful.button({ }, 1,
        function (c)
            client.focus = c
            c:raise()
        end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

local clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end, {description = "Toggle fullscreen", group = "Clients management"}),

    awful.key({ "Mod1"}, "F4",
        function (c)
            c:kill()
        end, {description = "Close", group = "Clients management"}),

    awful.key({modkey, "Shift"}, "q",
        function (c)
            c:kill()
        end, {description = "Close", group = "Clients management"}),

    awful.key({ modkey, "Control" }, "Return",
        function (c)
            c:swap(awful.client.getmaster())
        end, {description = "Move to master", group = "Clients management"}),

    awful.key({ modkey,           }, "t",
        function (c)
            c.ontop = not c.ontop
        end, {description = "Toggle keep on top", group = "Clients management"}),

    awful.key({ modkey, "Shift" }, "t",
        function (c)
            awful.titlebar.toggle(c)
        end,
        {description = "Toggle titlebar of active window", group = "Clients management"}),

    awful.key({ modkey, "Shift" }, "f",
        awful.client.floating.toggle,
    {description = "Toggle floating", group = "Clients management"}),

    awful.key({ modkey,  }, "s",
        function (c)
            c.sticky = not c.sticky
        end, {description = "Toogle sticky", group = "Clients management"}),

    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end, {description = "Minimize", group = "Clients management"}),

    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end, {description = "(Un)maximize", group = "Clients management"}),

    awful.key({ modkey, "Shift" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end, {description = "(Un)maximize vertically", group = "Clients management"}),

    awful.key({ modkey, "Control"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end, {description = "(Un)maximize horizontally", group = "Clients management"}),

    awful.key({ modkey, "Control"   }, "k",
        function (c)
            if awful.layout.get() ~= awful.layout.suit.floating then
                awful.client.incwfact(-0.05, c)
            end
        end, {description = "Decrease client factor", group = "Clients management"}),

    awful.key({ modkey, }, "g",
        function (c)
            local cp = (awful.placement.under_mouse + awful.placement.no_offscreen)
            cp(c)
        end, {description = "Put client under cursor", group = "Clients management"}),

    awful.key({ modkey, "Control"   }, "j",
        function (c)
            if awful.layout.get() ~= awful.layout.suit.floating then
                awful.client.incwfact( 0.05, c)
            end
        end, {description = "Increase client factor", group = "Clients management"})
)

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    {
        -- All clients will match this rule.
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.under_mouse + awful.placement.no_offscreen
        }
    },
    {
        rule_any = {
            instance = {"DTA",
                        "copyq"},
            class = {"Arandr",
                     "Gpick",
                     "Kruler",
                     "Wpa_gui",
                     "pinentry",
                     "veromix",
                     "xtightvncviewer",
                     "Lxappearance",
                     "Matplotlib",
                     "Nm-connection-editor",
                     "Msgcompose"},
            name = {"Event Tester",
                    "Figure *",
                    "Write: *",
                    "Wpicker",
                    "Mathpix Snipping Tool"},
            role = {"AlarmWindow",
                    "pop-up",}
        },
        properties = { floating = true }
    },
    {
        rule_any = {type = { "normal", "dialog" }},
        properties = { titlebars_enabled = true }
    },
    {
        rule_any = {class = { "qgis", "QGIS3"}},
        properties = { titlebars_enabled = true }
    },
    {
        rule_any = {class = {"todoist", "Todoist"}},
        properties = {
            tag = screen[1].tags[8],
            placement = awful.placement.top_right + awful.placement.stretch_down,
            width = dpi(420),
        }
    },
    {
        rule_any = {class = {"turtl", "Turtl"}},
        properties = {
            tag = screen[1].tags[8],
            width = dpi(420),
        }
    },
    {
        rule_any = {
            class = {"microsoft teams - preview", "Microsoft Teams - Preview"},
        },
        properties = {
            titlebars_enabled = false,
            focus = false,
            floating = true,
            tag = screen[1].tags[7],
            placement = awful.placement.no_offscreen + awful.placement.top_right,
        }
    },
    {
        rule = { name = "Microsoft Teams Notification" },
        properties = {
            floating = true,
            ontop = true,
            focus = false,
            focusable = false,
        }
    },
    {
        rule = { name = "galculator" },
        properties = { floating = true, ontop = true }
    },
    {
        rule = { name = "Media viewer" },
        properties = { floating = true, ontop = true, titlebars_enabled = false, fullscreen = true }
    },

    -- Rules for applications which I use with my tag configuration
    {
        rule = { name = "Telegram" },
        rule_any = {
            class = {"telegram-desktop", "TelegramDesktop"}
        },
        properties = {
            floating = true,
            sticky = true,
            tag = screen[1].tags[2]
        }
    },
    {
        rule_any = { class = {"Mail", "Thunderbird"} },
        properties = {
            tag = screen[1].tags[8],
        }
    },
    {
        rule_any = { class = {"spotify", "Spotify"} },
        properties = {
            tag = screen[1].tags[2],
        }
    },
    {
        rule_any = { class = {"discord"} },
        properties = {
            tag = screen[1].tags[7],
        }
    },
    {
        rule_any = { class = {"qbittorrent", "qBittorrent"} },
        properties = {
            tag = screen[1].tags[5],
        }
    },
}

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end
    if not startup and not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
        --awful.placement.no_overlap(c)
    end
    -- Uncomment for rounded corners
    -- c.shape = gears.shape.rounded_rect
    if c.maximized then
        c.border_width = 0
        -- Uncomment for rounded corners
        -- c.shape = gears.shape.rect
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    local buttons = gears.table.join(
        awful.button({  }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        -- awful.button({  }, 2, function() end),
        awful.button({  }, 3, function()
            client.focus = c
            if c.maximized  then
                c.maximized = false
            end
            c:raise()
            awful.mouse.client.resize(c)
        end)
        --awful.button({  }, 4, function(c) end),
        --awful.button({  }, 5, function(c) end)
    )
    awful.titlebar(c, {
            size = dpi(16),
            position = "top",
        }):setup{
        {
            -- Left
            layout  = wibox.layout.fixed.horizontal,
            awful.titlebar.widget.closebutton    (c), -- RED
            awful.titlebar.widget.minimizebutton (c), -- YELLOW
            awful.titlebar.widget.maximizedbutton(c), -- GREEN
            -- awful.titlebar.widget.floatingbutton (c),
            -- awful.titlebar.widget.ontopbutton    (c),
            -- awful.titlebar.widget.stickybutton   (c),
        },
        {
            -- Middle
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal,
        },
        {
            -- Right
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal(),
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Remove border when maximized
client.connect_signal("property::maximized", function(c)
    if c.maximized then
        c.border_width = 0
        -- Uncomment for rounded corners
        -- c.shape = gears.shape.rect
    else
        c.border_width = beautiful.border_width
        -- Uncomment for rounded corners
        -- c.shape = gears.shape.rounded_rect
    end
end)

-- Change border color
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

naughty.connect_signal("request::display", function(n)
    local actions = wibox.widget {
        notification = n,
        base_layout = wibox.widget {
            spacing = dpi(4),
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                id = "text_role",
                align = "center",
                valign = "center",
                font = beautiful.notification_font,
                widget = wibox.widget.textbox
            },
            shape = beautiful.notification_action_shape_normal,
            bg = beautiful.notification_action_bg_normal,
            forced_height = dpi(25),
            forced_width = dpi(94),
            widget = wibox.container.background
        },
        style = {
            underline_normal = false,
            underline_selected = true,
        },
        widget = naughty.list.actions
    }

    naughty.layout.box {
        notification = n,
        type = "notification",
        -- For antialiasing: The real shape is set in widget_template
        shape = gears.shape.rectangle,
        border_width = beautiful.notification_border_width,
        border_color = beautiful.notification_border_color,
        position = beautiful.notification_position,
        widget_template = {
            {
                {
                    {
                        naughty.widget.icon,
                        {
                            naughty.widget.title,
                            naughty.widget.message,
                            spacing = dpi(4),
                            layout  = wibox.layout.fixed.vertical,
                        },
                        spacing = beautiful.notification_margin,
                        layout  = wibox.layout.fixed.horizontal,
                    },
                    margins = beautiful.notification_margin,
                    widget = wibox.container.margin
                },
                {
                    actions,
                    visible = n.actions and #n.actions > 0,
                    margins = {
                        bottom = beautiful.notification_margin,
                        right  = beautiful.notification_margin,
                        left   = beautiful.notification_margin,
                    },
                    widget = wibox.container.margin
                },
                layout  = wibox.layout.fixed.vertical
            },
            forced_width = beautiful.notification_max_width,
            bg = beautiful.notification_bg,
            widget = wibox.container.background
        }
    }
end)

gears.timer.start_new(10, function()
    collectgarbage("step", 20000)
    return true
end)
