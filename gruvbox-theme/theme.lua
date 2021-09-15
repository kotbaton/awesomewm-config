local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gears = require("gears")
local theme_path = gears.filesystem.get_configuration_dir() .. "gruvbox-theme/"

local theme = {}

local function font(s, t)
    local base = "Hermit"
    s = s - 2 -- Hermit is bigger then Ubuntu Mono
    if t then
        return base .. " " .. t .. " " .. s
    else
        return base .. " " .. s
    end
end

theme.font          = font(13)

------ COLORS --------------
theme.colors = {
    white           = "#ebddb2",
    grey            = "#928374",
    darkGrey        = "#3c3836",
    black           = "#1d2021",

    red             = "#cc241d",
    green           = "#98971a",
    yellow          = "#d79921",
    blue            = "#458588",
    purple          = "#b16286",
    aqua            = "#689d6a",
    orange          = "#d65d0e",

    lightRed        = "#fb4934",
    lightGreen      = "#b8bb26",
    lightYellow     = "#fabd2f",
    lightBlue       = "#83a598",
    lightPurple     = "#d3869b",
    lightAqua       = "#83c07c",
    lightOrange     = "#fe9019"
}

theme.bg_normal     = theme.colors.black
theme.bg_focus      = theme.colors.black
theme.bg_urgent     = theme.colors.red
theme.bg_minimize   = theme.colors.black

theme.bg_systray    = theme.colors.black

theme.fg_normal     = theme.colors.white
theme.fg_focus      = theme.colors.grey
theme.fg_urgent     = theme.colors.black
theme.fg_minimize   = theme.colors.darkGrey

theme.useless_gap               = dpi(0)
theme.gap_single_client         = true
theme.maximized_honor_padding   = false

theme.border_width  = dpi(2)
theme.border_normal = theme.colors.black
theme.border_focus  = theme.colors.black
theme.border_marked = theme.colors.red

-- PROMPT --
theme.prompt_bg = '#00000000'
theme.prompt_fg = theme.colors.lightGreen
theme.prompt_fg_cursor = theme.colors.black
theme.prompt_bg_cursor = theme.colors.green

-- TAGLIST --
theme.taglist_fg_focus                          = theme.colors.white
theme.taglist_bg_focus                          = theme.colors.black .. 'AA'
theme.taglist_fg_occupied                       = theme.colors.grey
theme.taglist_bg_occupied                       = theme.colors.black .. '00'
-- theme.taglist_fg_urgent                      = nil
-- theme.taglist_bg_urgent                      = nil
-- theme.taglist_bg_empty                       = theme.colors.darkGrey
-- theme.taglist_fg_empty                       = theme.colors.grey
-- theme.taglist_bg_volatile                    = nil
-- theme.taglist_fg_volatile                    = nil
-- theme.taglist_squares_sel                    = nil
-- theme.taglist_squares_unsel                  = nil
-- theme.taglist_squares_sel_empty              = nil
-- theme.taglist_squares_unsel_empty            = nil
-- theme.taglist_squares_resize                 = nil
-- theme.taglist_disable_icon                   = nil
-- theme.taglist_font                           = "Ubuntu Mono Bold 12"
theme.taglist_spacing                           = 0
theme.taglist_shape                             = gears.shape.rectangle
theme.taglist_shape_border_width                = 0
theme.taglist_shape_border_color                = "#00000000"
-- theme.taglist_shape_empty                    = nil
-- theme.taglist_shape_border_width_empty       = nil
-- theme.taglist_shape_border_color_empty       = nil
-- theme.taglist_shape_focus                    = nil
-- theme.taglist_shape_border_width_focus       = nil
-- theme.taglist_shape_border_color_focus       = nil
-- theme.taglist_shape_urgent                   = nil
-- theme.taglist_shape_border_width_urgent      = nil
-- theme.taglist_shape_border_color_urgent      = nil
-- theme.taglist_shape_volatile                 = nil
-- theme.taglist_shape_border_width_volatile    = nil
-- theme.taglist_shape_border_color_volatile    = nil

-- TASKLIST --
theme.tasklist_fg_normal                        = theme.colors.grey
theme.tasklist_fg_focus                         = theme.colors.white
theme.tasklist_fg_minimize                      = theme.colors.grey
theme.tasklist_fg_urgent                        = theme.colors.red

local function make_gradient(color)
    local alpha_level = '22'
    return {
        type  = 'linear',
        from  = { 0, 0 },
        to    = { 0, dpi(24) },
        stops = {
            { 0.1, color },
            { 0.1, color .. alpha_level }
        }
    }
end

theme.tasklist_bg_normal                        = make_gradient(theme.colors.grey)
theme.tasklist_bg_focus                         = make_gradient(theme.colors.white)
theme.tasklist_bg_minimize                      = make_gradient(theme.colors.darkGrey)
theme.tasklist_bg_urgent                        = make_gradient(theme.colors.red)

-- Tasklist icons
theme.tasklist_sticky = ' '
theme.tasklist_ontop = ' '
theme.tasklist_floating = ' '
theme.tasklist_maximized = ' '
theme.tasklist_maximized_horizontal = ' '
theme.tasklist_maximized_vertical = ' '


-- theme.tasklist_bg_image_normal               = nil
-- theme.tasklist_bg_image_focus                = nil
-- theme.tasklist_bg_image_urgent               = nil
-- theme.tasklist_bg_image_minimize             = nil
theme.tasklist_disable_icon                     = false
-- theme.tasklist_disable_task_name             = nil
theme.tasklist_plain_task_name                  = false
-- theme.tasklist_font                          = nil
theme.tasklist_align                            = "center"
-- theme.tasklist_font_focus                    = nil
-- theme.tasklist_font_minimized                = nil
-- theme.tasklist_font_urgent                   = nil
theme.tasklist_spacing                          = dpi(8)
theme.tasklist_shape                            = gears.shape.rectangle
-- theme.tasklist_shape_border_width               = nil
-- theme.tasklist_shape_border_color               = nil
-- theme.tasklist_shape_focus                      = nil
-- theme.tasklist_shape_border_width_focus         = nil
-- theme.tasklist_shape_border_color_focus         = nil
-- theme.tasklist_shape_minimized                  = nil
-- theme.tasklist_shape_border_width_minimized     = nil
-- theme.tasklist_shape_border_color_minimized     = nil
-- theme.tasklist_shape_urgent                     = nil
-- theme.tasklist_shape_border_width_urgent        = nil
-- theme.tasklist_shape_border_color_urgent        = nil

-- NOTIFICATION --
-- theme.notification_shape                        = function(cr, width, height)
--     gears.shape.rounded_rect(cr, width, height, 16)
-- end

theme.notification_padding                      = dpi(8)
theme.notification_timeout                      = 5
-- theme.notification_max_height                   = dpi(200)
theme.notification_max_width                    = dpi(400)
theme.notification_position                     = 'top_right'
-- theme.notification_action_underline_normal = nil
-- theme.notification_action_underline_selected = nil
-- theme.notification_action_icon_only = nil
-- theme.notification_action_label_only = nil
theme.notification_action_shape_normal = gears.shape.rounded_rect
-- theme.notification_action_shape_selected = nil
-- theme.notification_action_shape_border_color_normal = nil
-- theme.notification_action_shape_border_color_selected = nil
-- theme.notification_action_shape_border_width_normal = nil
-- theme.notification_action_shape_border_width_selected = nil
-- theme.notification_action_icon_size_normal = nil
-- theme.notification_action_icon_size_selected = nil
theme.notification_action_bg_normal = theme.colors.black
-- theme.notification_action_bg_selected = theme.colors.yellow
-- theme.notification_action_fg_normal = nil
-- theme.notification_action_fg_selected = nil
-- theme.notification_action_bgimage_normal = nil
-- theme.notification_action_bgimage_selected = nil
-- theme.notification_shape_normal = nil
-- theme.notification_shape_selected = nil
-- theme.notification_shape_border_color_normal    = theme.colors.darkGrey .. '99'
-- theme.notification_shape_border_color_selected = nil
-- theme.notification_shape_border_width_normal   = 0
-- theme.notification_shape_border_width_selected = nil
theme.notification_icon_size                    = dpi(96)
theme.notification_icon_size_normal             = dpi(96)
theme.notification_icon_size_selected           = dpi(96)
-- theme.notification_bg_normal = nil
-- theme.notification_bg_selected = nil
-- theme.notification_fg_normal = nil
-- theme.notification_fg_selected = nil
-- theme.notification_bgimage_normal = nil
-- theme.notification_bgimage_selected = nil
theme.notification_font                         = theme.font
theme.notification_bg                           = theme.colors.darkGrey .. '99'
theme.notification_fg                           = theme.colors.white
theme.notification_border_width                 = 0
theme.notification_border_color                 = theme.colors.darkGrey .. '99'
-- theme.notification_shape = nil
theme.notification_opacity                      = 1.00
theme.notification_margin                       = dpi(8)
theme.notification_width                        = dpi(400)
-- theme.notification_height                       = dpi(100)
theme.notification_spacing                      = dpi(8)
-- theme.notification_icon_resize_strategy = nil

-- theme.calendar_style = nil
theme.calendar_font = font(14)
-- theme.calendar_spacing = 3
-- theme.calendar_week_numbers = nil
-- theme.calendar_start_sunday = nil
-- theme.calendar_long_weekdays = nil

-- snap
theme.snap_bg           = theme.colors.green .. '88'
theme.snap_border_width = dpi(8)
-- theme.snap_shape        = gears.shape.rounded_rect

-- menu
theme.menu_submenu_icon = theme_path .. "/icons/submenu.png"
theme.menu_height       = dpi(24)
theme.menu_width        = dpi(200)
-- theme.menu_font         = nil
theme.menu_border_color = theme.colors.black .. 'D9'
theme.menu_border_width = dpi(3)
theme.menu_fg_focus     = theme.colors.white
-- theme.menu_bg_focus     = theme.colors.white .. 'AA'
theme.menu_bg_focus     = {
    type = "linear",
    from  = { 0, 0 },
    to    = { 0, dpi(24) },
    stops = {
        { 0.1, theme.colors.blue  },
        { 0.1, theme.colors.blue .. '44' },
        { 0.5, theme.colors.blue .. '22' },
        { 0.9, theme.colors.blue .. '44' },
        { 0.9, theme.colors.blue },
    }
}
theme.menu_fg_normal    = theme.colors.white
theme.menu_bg_normal    = theme.colors.black .. '99'
-- theme.menu_submenu = nil

-- hotkeys
theme.hotkeys_bg                = theme.colors.black .. 'CC'
theme.hotkeys_fg                = theme.colors.white
theme.hotkeys_border_width      = dpi(4)
theme.hotkeys_border_color      = theme.colors.green
theme.hotkeys_shape             = gears.shape.rectangle
theme.hotkeys_modifiers_fg      = theme.colors.green
theme.hotkeys_label_bg          = theme.colors.green
theme.hotkeys_label_fg          = theme.colors.black
theme.hotkeys_font              = font(12, "Bold")
theme.hotkeys_description_font  = font(12)
theme.hotkeys_group_margin      = dpi(4)

theme.shutdown_icon = theme_path .. "icons/apps/shutdown.svg"
theme.reboot_icon = theme_path .. "icons/apps/reboot.svg"
theme.lock_icon = theme_path .. "icons/apps/lock.svg"
theme.hotkeys_icon = theme_path .. "icons/apps/hotkeys.svg"
theme.logout_icon = theme_path .. "icons/apps/logout.svg"

-- titlebar
-- theme.titlebar_fg_normal = nil
-- theme.titlebar_fg_focus = nil
-- theme.titlebar_bg_normal = theme.colors.black
-- theme.titlebar_bg_focus = theme.colors.green .. '99'
-- theme.titlebar_bgimage_normal = nil
-- theme.titlebar_fg = nil
-- theme.titlebar_bg = nil
-- theme.titlebar_bgimage = nil

-- Player widget
theme.player_widget_bg      = theme.colors.yellow
theme.player_widget_fg      = theme.colors.lightYellow
theme.player_widget_font    = font(13)
theme.player_widget_width   = dpi(290)

-- Volume widget
theme.volume_popup_border_color = theme.colors.green
theme.volume_popup_border_width = dpi(0)
theme.volume_popup_bg           = theme.colors.black .. 'DD'
theme.volume_bar_bg             = theme.colors.darkGrey .. '99'
theme.volume_bar_fg             = theme.colors.white
theme.volume_bar_fg_muted       = theme.colors.grey
theme.volume_bar_shape          = function(cr, width, height)
    gears.shape.rounded_bar(cr, width, height, 8)
end

-- System info widget
theme.si_weather_temp_font = font(16)
theme.si_weather_description_font = font(14)

theme.si_outer_border_color = theme.colors.green
theme.si_outer_border_width = dpi(0)
-- theme.si_outer_border_shape = function(cr, width, height)
--     gears.shape.partially_rounded_rect(cr, width, height,
--                                        false, false, false, true, 16)
-- end
theme.si_inner_border_color = theme.colors.black .. '00'
theme.si_inner_border_width = dpi(0)
theme.si_inner_bg           = theme.colors.black .. '00'
theme.si_outer_bg           = theme.colors.black .. 'DD'

theme.si_ram_bar_fg         = theme.colors.green
theme.si_ram_bar_bg         = theme.colors.darkGrey .. '99'
theme.si_swp_bar_fg         = theme.colors.yellow
theme.si_swp_bar_bg         = theme.colors.darkGrey .. '99'

theme.si_bar_shape          = function(cr, width, height)
    gears.shape.rounded_bar(cr, width, height, 8)
end

theme.si_cpu_graph_fg = theme.colors.green
theme.si_cpu_graph_bg = theme.colors.darkGrey .. '00'
theme.si_temp_font    = font(14, 'Bold')

-- Battery widget
theme.battery_charging_fg           = theme.colors.black
theme.battery_charging_bg           = theme.colors.green
theme.battery_discharging_normal_fg = theme.colors.white
theme.battery_discharging_normal_bg = theme.colors.darkGrey .. '00'
theme.battery_discharging_medium_fg = theme.colors.black
theme.battery_discharging_medium_bg = theme.colors.yellow
theme.battery_discharging_low_fg    = theme.colors.black
theme.battery_discharging_low_bg    = theme.colors.red

-- Create title bar icons
local recolor = gears.color.recolor_image
local circle_png = theme_path.."icons/titlebar_circle.png"

theme.titlebar_close_button_normal       = recolor(circle_png, theme.colors.darkGrey)
theme.titlebar_close_button_focus        = recolor(circle_png, theme.colors.red .. 'EE')
theme.titlebar_close_button_focus_hover  = recolor(circle_png, theme.colors.lightRed)
theme.titlebar_close_button_normal_hover = recolor(circle_png, theme.colors.lightRed)

theme.titlebar_minimize_button_normal       = recolor(circle_png, theme.colors.darkGrey)
theme.titlebar_minimize_button_focus        = recolor(circle_png, theme.colors.yellow .. 'EE')
theme.titlebar_minimize_button_focus_hover  = recolor(circle_png, theme.colors.lightYellow)
theme.titlebar_minimize_button_normal_hover = recolor(circle_png, theme.colors.lightYellow)

theme.titlebar_maximized_button_normal_inactive       = recolor(circle_png, theme.colors.darkGrey)
theme.titlebar_maximized_button_focus_inactive        = recolor(circle_png, theme.colors.green .. 'EE')
theme.titlebar_maximized_button_focus_inactive_hover  = recolor(circle_png, theme.colors.lightGreen)
theme.titlebar_maximized_button_normal_inactive_hover = recolor(circle_png, theme.colors.lightGreen)

theme.titlebar_maximized_button_normal_active       = recolor(circle_png, theme.colors.darkGrey)
theme.titlebar_maximized_button_focus_active        = recolor(circle_png, theme.colors.green .. 'EE')
theme.titlebar_maximized_button_focus_active_hover  = recolor(circle_png, theme.colors.lightGreen)
theme.titlebar_maximized_button_normal_active_hover = recolor(circle_png, theme.colors.lightGreen)

theme.titlebar_ontop_button_focus_inactive  = recolor(circle_png, theme.colors.blue)
theme.titlebar_floating_button_focus_inactive  = recolor(circle_png, theme.colors.purple)
theme.titlebar_sticky_button_focus_inactive  = recolor(circle_png, theme.colors.orange)

-- Layout icons
-- Don't load unneeded icons
local layout_icon_color = theme.colors.grey
-- theme.layout_fairh          = recolor(theme_path.."icons/layouts/fairh.png",        layout_icon_color)
-- theme.layout_fairv          = recolor(theme_path.."icons/layouts/fairv.png",        layout_icon_color)
theme.layout_floating       = recolor(theme_path.."icons/layouts/floating.png",     layout_icon_color)
-- theme.layout_magnifier      = recolor(theme_path.."icons/layouts/magnifier.png",    layout_icon_color)
-- theme.layout_max            = recolor(theme_path.."icons/layouts/max.png",          layout_icon_color)
-- theme.layout_fullscreen     = recolor(theme_path.."icons/layouts/fullscreen.png",   layout_icon_color)
-- theme.layout_tilebottom     = recolor(theme_path.."icons/layouts/tilebottom.png",   layout_icon_color)
theme.layout_tileleft       = recolor(theme_path.."icons/layouts/tileleft.png",     layout_icon_color)
theme.layout_tile           = recolor(theme_path.."icons/layouts/tile.png",         layout_icon_color)
-- theme.layout_tiletop        = recolor(theme_path.."icons/layouts/tiletop.png",      layout_icon_color)
-- theme.layout_spiral         = recolor(theme_path.."icons/layouts/spiral.png",       layout_icon_color)
-- theme.layout_dwindle        = recolor(theme_path.."icons/layouts/dwindle.png",      layout_icon_color)
-- theme.layout_cornernw       = recolor(theme_path.."icons/layouts/cornernw.png",     layout_icon_color)
-- theme.layout_cornerne       = recolor(theme_path.."icons/layouts/cornerne.png",     layout_icon_color)
-- theme.layout_cornersw       = recolor(theme_path.."icons/layouts/cornersw.png",     layout_icon_color)
-- theme.layout_cornerse       = recolor(theme_path.."icons/layouts/cornerse.png",     layout_icon_color)
-- theme.layout_centermaster   = recolor(theme_path.."icons/layouts/centermaster.png", layout_icon_color)
-- theme.layout_stack          = recolor(theme_path.."icons/layouts/stack.png",        layout_icon_color)
-- theme.layout_stackLeft      = recolor(theme_path.."icons/layouts/stackLeft.png",    layout_icon_color)

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.colors.white, theme.colors.black
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "Papirus"
return theme
