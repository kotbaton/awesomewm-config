-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local menu = require("modules.menus.clientmenu")

local tasklist_buttons = gears.table.join(
	awful.button({ }, 1,
		function (c)
			if c == client.focus then
				c.minimized = true
				awful.client.setslave(c)
			else
				-- Without this, the following
				-- :isvisible() makes no sense
				c.minimized = false
				if not c:isvisible() and c.first_tag then
					c.first_tag:view_only()
				end
				-- This will also un-minimize
				-- the client, if needed
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
			menu(c):show() 
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

local tasklist = awful.widget.tasklist(1,
		awful.widget.tasklist.filter.currenttags, 

		tasklist_buttons,

		{ 
			spacing = 8,
			layout = wibox.layout.horizontal,
		},

		list_update,

		wibox.layout.flex.horizontal()
)
tasklist:set_max_widget_size(170)

return tasklist
