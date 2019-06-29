local gears             = require("gears")
local awful             = require("awful")
local wibox             = require("wibox")
local beautiful         = require("beautiful")
local naughty           = require("naughty")
local hotkeys_popup     = require("awful.hotkeys_popup").widget

require("awful.autofocus")
require("awful.remote")

local modules           = require("modules")
local launcher          = require('setting').launcher
local dpi               = require("beautiful.xresources").apply_dpi

-- Set default apps
local terminal = require('setting').default_apps.terminal

-- Start autostart application
for _, app in ipairs(require('setting').autostart) do
    awful.spawn.once(app)
end

-- Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
            title = "Oops, there were errors during startup!",
        text = awesome.startup_errors })
end

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
naughty.config.defaults.border_width = dpi(4)
naughty.config.spacing = dpi(8)
naughty.config.padding = dpi(8)
naughty.config.defaults.timeout = 5

-- Theme init
beautiful.init(gears.filesystem.get_configuration_dir() .. "gruvbox-theme/theme.lua")

-- Default modkey.
local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
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
    -- modules.layouts.centermaster,
    modules.layouts.stack,
    modules.layouts.stack.left,
}

local function set_wallpaper(s)
    awful.spawn.with_shell("~/.fehbg", false)
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    local tags = modules.tools.tagnames.read(s.index)
    awful.tag(tags, s, awful.layout.layouts[1])

    -- Buttons for taglist and taglist widget
    local taglist_buttons = gears.table.join(
        awful.button({ }, 1,        function(t) t:view_only() end),
        awful.button({ modkey }, 1, function(t)
           if client.focus
                then
                client.focus:move_to_tag(t)
            end
        end),
        awful.button({ }, 2),
        awful.button({ }, 3,        awful.tag.viewtoggle),
        awful.button({ modkey }, 3, function(t)
            if client.focus
                then
                client.focus:toggle_tag(t)
            end
        end),
        awful.button({ }, 4,        function(t) awful.tag.viewnext(t.screen) end),
        awful.button({ }, 5,        function(t) awful.tag.viewprev(t.screen) end)
    )

    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.noempty, taglist_buttons)

    -- Promptbox widget
    s.mypromptbox = awful.widget.prompt()

    -- Layoutbox widget and buttons
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 2, function () awful.tag.togglemfpol(t) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end))
        )

    s.textclock = wibox.widget.textclock("%R")
    s.textclock:buttons(gears.table.join(awful.button({},1, function()
        if s.textclock.format == "%R" then
            s.textclock.format = "%d.%m.%y, %A %R"
        else
            s.textclock.format = "%R"
        end
    end)))

    s.keyboardlayout = awful.widget.keyboardlayout()

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
                modules.menus.clientmenu(c):show()
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
            spacing = dpi(8),
            layout = wibox.layout.flex.horizontal,
        },
    }
    s.mytasklist:set_max_widget_size(dpi(170))

    s.separator = wibox.widget.textbox(" ")

    s.nextEmptyTag = wibox.widget {
            markup = "<b>+</b>",
            align = "center",
            forced_width = dpi(16),
            widget = wibox.widget.textbox
    }

    s.nextEmptyTag:buttons(gears.table.join(awful.button({},1, function()
        awful.tag.viewnone()
        local tgs = awful.screen.focused().tags
        for i = 1, #tgs do
            if #tgs[i]:clients() == 0 then
                awful.tag.viewtoggle(tgs[i])
                break
            end
        end
    end)))

    s.wibar = awful.wibar({
            position = "top",
            screen = s,
            height = dpi(24),
            ontop = false,
            bg = beautiful.bg_normal,
        }):setup {
        {
            -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            modules.widgets.menu_button,
            s.mypromptbox,
            s.mylayoutbox,
            s.mytaglist,
            s.nextEmptyTag,
        },
        {
            -- Center widgets
            layout = wibox.layout.align.horizontal,
            s.separator,
            s.mytasklist,
            s.separator,
        },
        {
            -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            modules.widgets.player.widget,
            s.separator,
            modules.widgets.battery,
            modules.widgets.volume.text_widget,
            s.keyboardlayout,
            s.textclock,
            -- Add tray widget only on primary screen
            s.index == 1 and modules.widgets.tray.widget or s.separator,
            layout = wibox.layout.fixed.horizontal,
        },
        layout = wibox.layout.align.horizontal,
    }
end)

-- Set keys
local globalkeys = gears.table.join(
    ----------------------{ START APPS }--------------------------------------------
    awful.key({modkey, "Mod1"}, "1", function() awful.spawn(launcher.app1) end, {description=launcher.app1, group="Launcher"}),
    awful.key({modkey, "Mod1"}, "2", function() awful.spawn(launcher.app2) end, {description=launcher.app2, group="Launcher"}),
    awful.key({modkey, "Mod1"}, "3", function() awful.spawn(launcher.app3) end, {description=launcher.app3, group="Launcher"}),
    awful.key({modkey, "Mod1"}, "4", function() awful.spawn(launcher.app4) end, {description=launcher.app4, group="Launcher"}),
    awful.key({modkey, "Mod1"}, "5", function() awful.spawn(launcher.app5) end, {description=launcher.app5, group="Launcher"}),
    awful.key({modkey, "Mod1"}, "6", function() awful.spawn(launcher.app6) end, {description=launcher.app6, group="Launcher"}),
    awful.key({modkey, "Mod1"}, "7", function() awful.spawn(launcher.app7) end, {description=launcher.app7, group="Launcher"}),
    awful.key({modkey, "Mod1"}, "8", function() awful.spawn(launcher.app8) end, {description=launcher.app8, group="Launcher"}),
    awful.key({modkey, "Mod1"}, "9", function() awful.spawn(launcher.app9) end, {description=launcher.app9, group="Launcher"}),

    awful.key({ modkey }, "r",
        function ()
            awful.screen.focused().mypromptbox:run()
        end, {description = "run prompt", group = "Launcher"}),

    awful.key({ modkey,           }, "Return",
        function ()
            awful.spawn(terminal)
        end, {description = "open a terminal", group = "Launcher"}),

    awful.key({"Control", "Mod1"}, "w",
        function()
            awful.spawn("/home/sheh/.scripts/trans_clip.sh", false)
        end, {description = "Translate text from selection", group = "Launcher"}),

    awful.key({"Control", "Mod1"}, "q",
        function()
            awful.spawn("/home/sheh/.scripts/trans_clip_choose.sh", false)
        end, {description = "Translate text from selection with choosing language", group = "Launcher"}),

    awful.key({"Control", "Mod1"}, "e",
        function()
            awful.spawn("/home/sheh/.scripts/brief_trans.sh", false)
        end, {description = "Translate text", group = "Launcher"}),

    awful.key({"Control", "Mod1"}, "c",
        function()
            awful.spawn("galculator", false)
        end, {description = "Galculator", group = "Launcher"}),

    awful.key({modkey}, "c", function()
        local textclock =  awful.screen.focused().textclock
        if textclock.format == "%R" then
            textclock.format = "%d.%m.%y, %A %R"
        else
            textclock.format = "%R"
        end
    end, {description = "Toggle clock format (with date or not)", group = "Launcher"}),

    awful.key({"Control", "Mod1"}, "l",
        function()
            awful.spawn("light-locker-command --lock")
        end, {description = "lock", group = "awesome"}),

    ----------------------{ AWESOME }--------------------------------------------
    awful.key({ modkey, "Control" }, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),

    awful.key({ modkey, "Shift"   }, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "space",
        awful.screen.focused().keyboardlayout.next_layout,
        {description="change language", group="awesome"}),

    awful.key({ modkey, "Shift"   }, "a", hotkeys_popup.show_help, {description="show help", group="awesome"}),

    awful.key({ modkey,           }, "x",
        function ()
            awful.prompt.run{
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"}
        end, {description = "lua execute prompt", group = "awesome"}),

    awful.key({ modkey,           }, "a",
        function ()
            modules.menus.mainmenu:toggle()
        end, {description = "show main menu", group = "awesome"}),

    awful.key({ modkey,           }, "q",
        function ()
            modules.widgets.tray.toggle()
        end, {description = "show system tray", group = "awesome"}),

    awful.key({ modkey,           }, "b",
        function ()
            show_battery_status()
        end, {description = "show battery status", group = "awesome"}),

    ----------------------{ SOUND }--------------------------------------------
    awful.key({ }, "XF86AudioRaiseVolume",
        function()
            modules.widgets.volume.control("increase")
        end, {description="Increase volume", group="Volume"}),

    awful.key({ }, "XF86AudioLowerVolume",
        function()
            modules.widgets.volume.control("decrease")
        end, {description="Decrease volume", group="Volume"}),

    awful.key({ }, "XF86AudioMute",
        function()
            modules.widgets.volume.control("toggle")
        end, {description="Mute volume", group="Volume"}),

    --------------------------{ BRIGHTNESS }----------------------------------
    awful.key({ }, "XF86MonBrightnessUp",
        function()
            awful.spawn("bash -c 'xbacklight -inc 10'", false)
        end, {description="Increase screen brightness", group="Brightness"}),

    awful.key({ }, "XF86MonBrightnessDown",
        function()
            awful.spawn("bash -c 'xbacklight -dec 10'", false)
        end, {description="Decrease screen brightness", group="Brightness"}),

    awful.key({ "Shift" }, "XF86MonBrightnessUp",
        function()
            awful.spawn("bash -c 'xbacklight -set 100'", false)
        end, {description="Set screen brightness on 100", group="Brightness"}),

    awful.key({ "Shift" }, "XF86MonBrightnessDown",
        function()
            awful.spawn("bash -c 'xbacklight -set 0'", false)
        end, {description="Set screen brightness on 0", group="Brightness"}),

    ----------------------{ PRINTSCREEN }--------------------------------------------
    awful.key({ }, "Print", nil,
        function()
            awful.util.spawn(gears.filesystem.get_configuration_dir() .. "scripts/make_screenshot.sh", false)
        end, { description = "Make screenshot of fullscreen", group = "Screenshot" }),

    awful.key({ "Shift" }, "Print", nil,
        function()
            awful.util.spawn(gears.filesystem.get_configuration_dir() .. "scripts/make_screenshot.sh -s", false)
        end, { description = "Make screenshot of selection", group = "Screenshot" }),

    awful.key({ "Shift", "Control" }, "Print", nil,
        function()
            awful.util.spawn(gears.filesystem.get_configuration_dir() .. "scripts/make_screenshot.sh -se", false)
        end, { description = "Make screenshot and open them in gimp", group = "Screenshot" }),

    awful.key({ "Control"}, "Print", nil,
        function()
            awful.util.spawn(gears.filesystem.get_configuration_dir() .. "scripts/make_screenshot.sh -e", false)
        end, { description = "Make screenshot of selection and open then in gimp", group = "Screenshot" }),

    ----------------------{ PLAYER }--------------------------------------------
    awful.key({ modkey }, "F1",
        function()
            modules.widgets.player.control.toggle()
        end, {description="Toggle Pause", group="player"}),

    awful.key({ modkey }, "F2",
        function()
            modules.widgets.player.control.prev()
        end, {description="Prev", group="player"}),

    awful.key({ modkey }, "F3",
        function()
            modules.widgets.player.control.next()
        end, {description="Next", group="player"}),

    ----------------------{ TAGS }--------------------------------------------
    awful.key({ modkey,}, "p", function() awful.tag.togglemfpol(t) end, {description = "toggle master fill police", group = "tag"}),

    awful.key({ modkey,}, "`",     awful.tag.history.restore, {description = "go back", group = "tag"}),

    awful.key({ modkey,}, "-", function() awful.tag.setgap(awful.tag.getgap(t) - 5) end, {description = "decrese gaps", group = "tag"}),

    awful.key({ modkey,}, "=", function() awful.tag.setgap(awful.tag.getgap(t) + 5) end, {description = "increase gaps", group = "tag"}),

    awful.key({ modkey,}, "0", function() awful.tag.setgap(0) end, {description = "set zero gaps", group = "tag"}),

    awful.key({ modkey,}, "i",
        function()
            awful.prompt.run {
                prompt       = "Rename tag: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = function(new_name)
                    local t = awful.screen.focused().selected_tag -- Get current tag
                    if t then -- If success, check does we got text or no
                        if not new_name or #new_name == 0 -- If length of input text 0 set default tag name
                            then
                            t.name = t.index
                        else
                            t.name = t.index .. ":" .. new_name
                        end
                    end
                    -- Write tagnames in cache file
                    local scr = awful.screen.focused()
                    modules.tools.tagnames.write(scr.index, scr.tags)
                end
            }
        end, {description = "Rename active tag", group = "tag"}),

    awful.key({ modkey,           }, "l",
        function ()
            awful.tag.incmwfact( 0.05)
        end, {description = "increase master width factor", group = "layout"}),

    awful.key({ modkey,           }, "h",
        function ()
            awful.tag.incmwfact(-0.05)
        end, {description = "decrease master width factor", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "l",
        function ()
            awful.tag.incnmaster( 1, nil, true)
        end, {description = "increase the number of master clients", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "h",
        function ()
            awful.tag.incnmaster(-1, nil, true)
        end, {description = "decrease the number of master clients", group = "layout"}),

    awful.key({ modkey, "Control" }, "l",
        function ()
            awful.tag.incncol( 1, nil, true)
        end, {description = "increase the number of columns", group = "layout"}),

    awful.key({ modkey, "Control" }, "h",
        function ()
            awful.tag.incncol(-1, nil, true)
        end, {description = "decrease the number of columns", group = "layout"}),

    awful.key({ "Mod1",           }, "space",
        function ()
            awful.layout.inc( 1)
        end, {description = "select next", group = "layout"}),

    awful.key({ "Mod1", "Shift"   }, "space",
        function ()
            awful.layout.inc(-1)
        end, {description = "select previous", group = "layout"}),

    ----------------------{ WINDOWS CONTROL }--------------------------------------------
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
        end, {description = "focus next by index", group = "client"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end, {description = "focus next by index", group = "client"}),

    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end, {description = "focus previous by index", group = "client"}),

    awful.key({ modkey, "Shift"   }, "j",
        function ()
            awful.client.swap.byidx(  1)
        end, {description = "swap with next client by index", group = "client"}),

    awful.key({ modkey, "Shift"   }, "k",
        function ()
            awful.client.swap.byidx( -1)
        end, {description = "swap with previous client by index", group = "client"}),

    awful.key({ modkey, }, "o",
        function ()
            awful.screen.focus_relative(1)
        end, {description = "focus the next screen", group = "screen"}),

    awful.key({ modkey, "Shift"}, "o",
        function ()
            local c = client.focus
            if c then c:move_to_screen() end
        end, {description = "move focused window on next screen", group = "screen"}),

    awful.key({ modkey,           }, "u",
        function()
            awful.client.urgent.jumpto()
        end, {description = "jump to urgent client", group = "client"}),

    awful.key({ modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end, {description = "restore minimized", group = "client"})
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
            {description = "View tag", group = "tag"}),

        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {descriptiond = "Toggle tag", group = "tag"}),

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
            {description = "Move client to tag", group = "tag"}),

        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
        {description = "Add client to tag", group = "tag"}))
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
    awful.button({ modkey }, 2, function(c) c.maximized = not c.maximized end),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

local clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end, {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey, "Shift"   }, "c",
        function (c)
            c:kill()
        end, {description = "close", group = "client"}),

    awful.key({ "Mod1"}, "F4",
        function (c)
            c:kill()
        end, {description = "close", group = "client"}),

    awful.key({ modkey, "Control" }, "Return",
        function (c)
            c:swap(awful.client.getmaster())
        end, {description = "move to master", group = "client"}),

    awful.key({ modkey,           }, "t",
        function (c)
            c.ontop = not c.ontop
        end, {description = "toggle keep on top", group = "client"}),

    awful.key({ modkey, "Shift" }, "t",
        function (c)
            awful.titlebar.toggle(c)
        end, {description = "toggle titlebar of active window", group = "client"}),

    awful.key({ modkey, "Shift" }, "f",  awful.client.floating.toggle, {description = "toggle floating", group = "client"}),

    awful.key({ modkey,  }, "s",
        function (c)
            c.sticky = not c.sticky
        end, {description = "toogle sticky", group = "client"}),

    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end, {description = "minimize", group = "client"}),

    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end, {description = "(un)maximize", group = "client"}),

    awful.key({ modkey, "Shift" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end, {description = "(un)maximize vertically", group = "client"}),

    awful.key({ modkey, "Control"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end, {description = "(un)maximize horizontally", group = "client"}),

    awful.key({ modkey, "Control"   }, "k",
        function (c)
            if awful.layout.get() ~= awful.layout.suit.floating then
                awful.client.incwfact(-0.05, c)
            end
        end, {description = nil, group = "client"}),

    awful.key({ modkey, "Control"   }, "j",
        function (c)
            if awful.layout.get() ~= awful.layout.suit.floating then
                awful.client.incwfact( 0.05, c)
            end
        end, {description = nil, group = "client"})
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
            instance = {"DTA","copyq"},
            class = {"Arandr","Gpick","Kruler","Wpa_gui","pinentry","veromix","xtightvncviewer"},
            name = {"Event Tester",},
            role = {"AlarmWindow","pop-up",}
        },
        properties = { floating = true }
    },
    {
        rule_any = {type = { "normal", "dialog" }},
        properties = { titlebars_enabled = true }
    },
    {
        rule = { name = "galculator" },
        properties = { floating = true, ontop = true }
    },
    {
        rule = { class = "Matplotlib" },
        properties = { floating = true }
    },
    {
        rule = { name = "Figure *" },
        properties = { floating = true }
    },
    {
        rule = { name = "Media viewer" },
        properties = { floating = true, ontop = true, titlebars_enabled = false, fullscreen = true }
    },
}

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end
    if not startup and not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.under_mouse(c)
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
        awful.button({  }, 2, function()
            client.focus = c
            c.maximized = not c.maximized
        end),
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
            -- awful.titlebar.widget.floatingbutton (c), -- BLUE
            -- awful.titlebar.widget.ontopbutton    (c), -- PURPLE
            -- awful.titlebar.widget.stickybutton   (c), -- ORANGE
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

gears.timer.start_new(10, function()
    collectgarbage("step", 20000)
    return true
end)
