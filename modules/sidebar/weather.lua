local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful") 
local dpi       = require("beautiful.xresources").apply_dpi

local user = require("settings").user

local weather_text = wibox.widget {
    align         = 'center',
    valign        = 'center',
    text          = '0°C',
    forced_height = dpi(40),
    wrap          = 'word',
    font          = beautiful.si_weather_temp_font or beautiful.font,
    widget        = wibox.widget.textbox
}
local weather_description = wibox.widget {
    align         = 'center',
    valign        = 'center',
    text          = 'Wait for update',
    forced_height = dpi(20),
    wrap          = 'word',
    font          = beautiful.si_weather_description_font or beautiful.font,
    widget        = wibox.widget.textbox
}

local function weather_update()
    local key = user.api_key
    local city_id = user.city_id
    local command = [[
        bash -c '
        KEY="]]..key..[["
        CITY="]]..city_id..[["

        weather=$(curl -sf "http://api.openweathermap.org/data/2.5/weather?APPID=$KEY&id=$CITY&units=metric")

        if [ ! -z "$weather" ]; then
            weather_temp=$(echo "$weather" | jq ".main.temp" | cut -d "." -f 1)
            weather_description=$(echo "$weather" | jq -r ".weather[].description" | head -1)
            weather_icon=$(echo "$weather" | jq -r ".weather[].icon" | head -1)

            echo "$weather_icon;$weather_temp;$weather_description"
        else
            echo "0;0;Weather unavailable"
        fi
  ']]

    awful.spawn.easy_async(command, function(stdout)
        local icon_code, temp, description = stdout:match("(%w+);([-%d]+);([ %w]+)")
        local icon = ''

        icon_code = icon_code or '0'
        temp = temp or '0'
        description = description or 'Weather unavailable'

        if icon_code == '01d' then
            icon = ''
        elseif icon_code == '01n' then
            icon = ''
        elseif icon_code == '02d' then
            icon = ''
        elseif icon_code == '02n' then
            icon = ''
        elseif icon_code:find('02') or icon_code:find('03') or icon_code:find('04') then
            icon = ''
        elseif icon_code:find('09') then
            icon = ''
        elseif icon_code == '10d' then
            icon = ''
        elseif icon_code == '10n' then
            icon = ''
        elseif icon_code:find('11') then
            icon = ''
        elseif icon_code:find('13') then
            icon = ''
        elseif icon_code:find('50') then
            icon = ''
        else
            icon = '×'
        end

        weather_text:set_text(icon .. " " .. temp .. "°C")
        weather_description:set_text(description)
    end)
end

local weather_widget = wibox.widget {
    weather_text,
    weather_description,
    layout = wibox.layout.fixed.vertical,
}

return {
    widget = weather_widget,
    update = weather_update
}
