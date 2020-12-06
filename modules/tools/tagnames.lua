local gears = require("gears")
local io = io

local tagnames = {}

function screen_name(s)
    local sg = s.geometry
    local screenName = sg.width .. sg.height .. sg.x .. sg.y
    return screenName
end

function tagnames.read(screen)
    local cache_dir = gears.filesystem.get_cache_dir()
    if not gears.filesystem.dir_readable(cache_dir)
    then
        gears.filesystem.make_directories(cache_dir)
    end

    local tagnamesfile = cache_dir .. "tagnames" .. screen_name(screen) .. ".txt"
    if not gears.filesystem.file_readable(tagnamesfile)
    then
        return { "1", "2", "3", "4", "5", "6", "7", "8", "9"}
    end

    local names = {}
    file = io.open(tagnamesfile, "r")
    while true do
        local line = file:read()
        if line == nil then break end
        names[#names + 1] = line
    end
    file:close()
    return names
end

function tagnames.write(screen)
    local tags = screen.tags
    local cache_dir = gears.filesystem.get_cache_dir()
    if not gears.filesystem.dir_readable(cache_dir)
    then
        return false
    end

    local names = {}
    for i = 1, #tags do
        names[i] = tags[i].name
    end

    local tagnamesfile = cache_dir .. "tagnames" .. screen_name(screen) .. ".txt"
    file = io.open(tagnamesfile, "w")
    for i = 1, #names do
        file:write(names[i], "\n")
    end
    file:close()
end

return tagnames
