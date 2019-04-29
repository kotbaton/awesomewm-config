local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir() .. "gruvbox-theme/theme.lua")

local tag_info_popup = {}

tag_info_popup.text = wibox.widget {
	text = ' ... ',
	vailgn = 'center',
	align = 'canter',
	font = 'Ubuntu Mono Bold 14',
	widget = wibox.widget.textbox,
}

tag_info_popup.popup = awful.popup {
	widget = {
		tag_info_popup.text,	
		layout = wibox.layout.fixed.vertical,
	},
	placement = awful.placement.centered,
    screen = awful.screen.focused(),
	ontop = true,
	border_width = 3,
	border_color = beautiful.colors.green,
	type = 'normal',
	visible = false,
}

function tag_info_popup.show(t)
	local text = ''
	text = text .. ' Layout: ' .. t.layout.name .. ' \n'
	text = text .. ' Master width: ' .. t.master_width_factor .. ' \n'
	text = text .. ' Fill policy: ' .. t.master_fill_policy .. ' \n'
	text = text .. ' Gaps: ' .. t.gap .. ' \n'
	text = text .. ' Master count: ' .. t.master_count .. ' \n'
	text = text .. ' Column count: ' .. t.column_count
	tag_info_popup.text:set_text(text)
	tag_info_popup.popup.visible = true
    tag_info_popup.popup.screen = awful.screen.focused()
	if tag_info_popup.timer.started then
		tag_info_popup.timer:again()
	else
		tag_info_popup.timer:start()
	end
end

tag_info_popup.timer = gears.timer {
	timeout = 3,
	callback = function()
		tag_info_popup.popup.visible = false
	end,
}

return tag_info_popup
