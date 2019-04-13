local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gears = require("gears")
local theme_path = gears.filesystem.get_configuration_dir() ..  "gruvbox-theme/"

local theme = {}

theme.font          = "Ubuntu Mono 13"

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

theme.border_width  = dpi(4)
theme.border_normal = theme.colors.darkGrey .. 'CC'
theme.border_focus  = theme.colors.green .. 'CC'
theme.border_marked = theme.colors.red .. 'CC'

-- taglist
theme.taglist_fg_focus                          = theme.colors.white
theme.taglist_bg_focus                          = theme.colors.darkGrey
theme.taglist_fg_occupied                       = theme.colors.white
theme.taglist_bg_occupied                       = theme.colors.black
-- theme.taglist_fg_urgent                      = nil
-- theme.taglist_bg_urgent                      = nil
-- theme.taglist_bg_empty                          = theme.colors.darkGrey
-- theme.taglist_fg_empty                          = theme.colors.grey
-- theme.taglist_bg_volatile                    = nil
-- theme.taglist_fg_volatile                    = nil
-- theme.taglist_squares_sel                    = nil
-- theme.taglist_squares_unsel                  = nil
-- theme.taglist_squares_sel_empty              = nil
-- theme.taglist_squares_unsel_empty            = nil
-- theme.taglist_squares_resize                 = nil
-- theme.taglist_disable_icon                   = nil
-- theme.taglist_font                              = "Ubuntu Mono Bold 12"
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

theme.tasklist_fg_normal                        = theme.colors.black
theme.tasklist_fg_focus                         = theme.colors.black
theme.tasklist_fg_minimize                      = theme.colors.black
theme.tasklist_fg_urgent                        = theme.colors.black
theme.tasklist_bg_normal                        = theme.colors.grey
theme.tasklist_bg_focus                         = theme.colors.green
theme.tasklist_bg_minimize                      = theme.colors.darkGrey
theme.tasklist_bg_urgent                        = theme.colors.red
-- theme.tasklist_bg_image_normal               = nil
-- theme.tasklist_bg_image_focus                = nil
-- theme.tasklist_bg_image_urgent               = nil
-- theme.tasklist_bg_image_minimize             = nil
theme.tasklist_disable_icon                     = true
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

-- notification
theme.notification_font                         = "Ubuntu Bold 12"
theme.notification_bg                           = theme.colors.black
theme.notification_fg                           = theme.colors.white
theme.notification_border_color                 = theme.colors.green .. 'AA'
theme.notification_border_width                 = 5
theme.notification_shape                        = gears.shape.rect
theme.notification_opacity                      = 0.90
theme.notification_margin                       = 16
theme.notification_width                        = 400
-- theme.notification_height                       = nil
theme.notification_icon_size                    = icon_size or 96
theme.notification_max_width                    = 400
-- theme.notification_max_height                   = nil

-- calendar
-- theme.calendar_style = nil
-- theme.calendar_font = nil
-- theme.calendar_spacing = 3
-- theme.calendar_week_numbers = nil
-- theme.calendar_start_sunday = nil
-- theme.calendar_long_weekdays = nil

-- snap
theme.snap_bg           = theme.colors.lightGreen .. '99'
theme.snap_border_width = dpi(10)
theme.snap_shape        = gears.shape.rectangle

-- menu
theme.menu_submenu_icon = theme_path .."/icons/submenu.png"
theme.menu_height       = dpi(24)
theme.menu_width        = dpi(256)
theme.menu_font         = "Ubuntu 11 Mono"
theme.menu_border_color = theme.colors.green .. 'AA'
theme.menu_border_width = dpi(3)
theme.menu_fg_focus     = theme.colors.white
theme.menu_bg_focus     = theme.colors.green .. 'AA'
theme.menu_fg_normal    = theme.colors.white
theme.menu_bg_normal    = theme.colors.black .. 'AA'
-- theme.menu_submenu = nil

-- hotkeys
theme.hotkeys_bg = theme.colors.white
theme.hotkeys_fg = theme.colors.black
theme.hotkeys_border_width = 4
theme.hotkeys_border_color = theme.colors.darkGrey
theme.hotkeys_shape = gears.shape.rounded_rect
theme.hotkeys_modifiers_fg = theme.colors.black
-- theme.hotkeys_label_bg = nil
-- theme.hotkeys_label_fg = nil
theme.hotkeys_font = "Ubuntu Mono Bold 12"
theme.hotkeys_description_font = "Ubuntu 11"
theme.hotkeys_group_margin = 5

theme.terminal_icon = theme_path.."icons/apps/terminal.svg"
theme.chrome_icon = theme_path.."icons/apps/chrome.svg"
theme.thunar_icon = theme_path.."icons/apps/thunar.svg"
theme.telegram_icon = theme_path.."icons/apps/telegram.svg"
theme.music_icon = theme_path.."icons/apps/music.png"
theme.shutdown_icon = theme_path .. "icons/apps/shutdown.svg"
theme.reboot_icon = theme_path .. "icons/apps/reboot.svg"
theme.lock_icon = theme_path .. "icons/apps/lock.svg"
theme.hotkeys_icon = theme_path .. "icons/apps/hotkeys.svg"
theme.logout_icon = theme_path .. "icons/apps/logout.svg"

-- Define the image to load
theme.titlebar_close_button_normal = theme_path.."icons/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = theme_path.."icons/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = theme_path.."icons/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = theme_path.."icons/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = theme_path.."icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = theme_path.."icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = theme_path.."icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = theme_path.."icons/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = theme_path.."icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = theme_path.."icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = theme_path.."icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = theme_path.."icons/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = theme_path.."icons/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = theme_path.."icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = theme_path.."icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = theme_path.."icons/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = theme_path.."icons/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = theme_path.."icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = theme_path.."icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = theme_path.."icons/titlebar/maximized_focus_active.png"

-- You can use your own layout icons like this:
theme.layout_fairh = theme_path.."icons/layouts/fairh.png"
theme.layout_fairv = theme_path.."icons/layouts/fairv.png"
theme.layout_floating  = theme_path.."icons/layouts/floating.png"
theme.layout_magnifier = theme_path.."icons/layouts/magnifier.png"
theme.layout_max = theme_path.."icons/layouts/max.png"
theme.layout_fullscreen = theme_path.."icons/layouts/fullscreen.png"
theme.layout_tilebottom = theme_path.."icons/layouts/tilebottom.png"
theme.layout_tileleft   = theme_path.."icons/layouts/tileleft.png"
theme.layout_tile = theme_path.."icons/layouts/tile.png"
theme.layout_tiletop = theme_path.."icons/layouts/tiletop.png"
theme.layout_spiral  = theme_path.."icons/layouts/spiral.png"
theme.layout_dwindle = theme_path.."icons/layouts/dwindle.png"
theme.layout_cornernw = theme_path.."icons/layouts/cornernw.png"
theme.layout_cornerne = theme_path.."icons/layouts/cornerne.png"
theme.layout_cornersw = theme_path.."icons/layouts/cornersw.png"
theme.layout_cornerse = theme_path.."icons/layouts/cornerse.png"


-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.fg_normal, theme.bg_normal
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "Papirus"
return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
