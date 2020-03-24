local beautiful         = require('beautiful')

local helpers = {}

function helpers.highlighter(b, a)
    local cmd = b..'ZZZCURSORZZZ'..a

    -- Highlight delimiter
    local ind = cmd:find('//')
    if ind then
        cmd = '<span foreground="' .. beautiful.colors.white .. '">'
        .. cmd:sub(1, ind-1) .. '</span>'
        .. '<b><span foreground="' .. beautiful.colors.purple .. '">'
        .. cmd:sub(ind, ind+1) .. '</span></b>'
        .. '<span foreground="' .. beautiful.colors.grey .. '">'
        .. cmd:sub(ind+2) .. '</span>'
    else
        cmd = '<span foreground="' .. beautiful.colors.white .. '">'
        .. cmd .. '</span>'

    end

    local pos = cmd:find('ZZZCURSORZZZ')
    b,a = cmd:sub(1, pos-1), cmd:sub(pos+12, #cmd)
    return b,a
end


function helpers.split_text(text)
    local title, notes = '', ''
    local ind = text:find('//')
    if ind then
        title = text:sub(1, ind - 1)
        notes = text:sub(ind + 2)
    else
        title = text
    end

    return title, notes
end


return helpers
