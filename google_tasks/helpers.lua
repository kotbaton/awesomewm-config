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

    cmd = cmd:gsub('%[%d%d?%]', '<b><span foreground="'
                                 .. beautiful.colors.red
                                 .. '">%1</span></b>')

    cmd = cmd:gsub('%[%d%d?[./-]%d%d%]', '<b><span foreground="'
                                        .. beautiful.colors.red
                                        .. '">%1</span></b>')

    cmd = cmd:gsub('%[%d%d?[./-]%d%d[./-]%d%d%d%d%]', '<b><span foreground="'
                                                     .. beautiful.colors.red
                                                     .. '">%1</span></b>')

    local pos = cmd:find('ZZZCURSORZZZ')
    b,a = cmd:sub(1, pos-1), cmd:sub(pos+12, #cmd)
    return b,a
end


function helpers.split_text(text)
    text = text:gsub('\"', '\\"') -- Put \ before "

    -- Find date
    local ind1, ind2 = text:find('%[%d'), text:find('%d%]')
    local date = {}
    if ind1 and ind2 and (ind1 < ind2) then
        -- Get string with date
        date_string = text:sub(ind1, ind2+1)

        -- Delete date from text
        text = text:sub(1, ind1-1) .. text:sub(ind2+2)

        date.day, date.month, date.year = date_string:match('(%d%d?)[./-](%d%d)[./-](%d%d%d%d)')
        if date.day == nil then
            date.day, date.month = date_string:match('(%d%d?)[./-](%d%d)')
            if date.day == nil then
                date.day = date_string:match('(%d%d?)')
                date.month = os.date('*t').month
            end
            date.year = os.date('*t').year
        end
    end

    -- Split text on title and notes
    local title, notes = '', ''
    local ind = text:find('//')
    if ind then
        title = text:sub(1, ind - 1)
        notes = text:sub(ind + 2)
    else
        title = text
    end

    local timestamp = ''
    if date.day ~= nil then
        timestamp = string.format("%04d-%02d-%02dT00:00:00.000Z",
                                  date.year, date.month, date.day)
    end

    return title, notes, timestamp
end


return helpers
