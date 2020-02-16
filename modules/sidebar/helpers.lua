local wibox     = require("wibox")
local dpi       = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful") 

local function decorator(w, vmargin, hmargin, fg)
    return {
        {
            w,
            bg                 = beautiful.si_inner_bg,
            fg                 = fg or beautiful.fg_normal,
            shape_border_color = beautiful.si_inner_border_color or beautiful.colors.darkGrey,
            shape_border_width = beautiful.si_inner_border_width or dpi(1),
            widget             = wibox.container.background
        },
        forced_width    = dpi(200),
        top             = vmargin or dpi(2),
        bottom          = vmargin or dpi(2),
        left            = hmargin or dpi(20),
        right           = hmargin or dpi(20),
        widget          = wibox.container.margin,
    }
end

local function add_label(label, widget, label_size)
    label_size = label_size or 15
    return {
        {
            text            = label,
            font            = "Hermit " .. label_size,
            align           = 'center',
            valign          = 'center',
            forced_width    = dpi(50),
            forced_height   = dpi(32),
            widget          = wibox.widget.textbox,
        },
        widget,
        layout = wibox.layout.align.horizontal,
    }
end

return {
    add_label = add_label,
    decorator = decorator,
}
