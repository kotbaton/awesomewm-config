local math = math
local screen = screen

--[[
--  This layout places windows
--  in this way:
-- 
--    +---+-----+---+
--    | 5 |     | 2 |
--    |   |     +---+
--    +---+  1  | 3 |
--    |   |     +---+
--    | 6 |     | 4 |
--    +---+-----+---+
--
--  All master windows stay in
--  center and slaves near edges
--]]

local centermaster = {}

local function arrange(p)
    local t   = p.tag or screen[p.screen].selected_tag
    local wa  = p.workarea
    local cls = p.clients

    if #cls == 0 then return end

    local mstrWidthFact     = t.master_width_factor
    local mstrNumber        = math.min(math.max(t.master_count, 1), #cls)
    local mstrFillPolicy    = t.master_fill_policy

    local mstrWidth         = math.floor(wa.width * mstrWidthFact)
    local mstrHeight        = math.floor(wa.height / mstrNumber)

    local leftSlavesNumber  = math.floor((#cls - mstrNumber) / 2)
    local rightSlavesNumber = #cls - mstrNumber - leftSlavesNumber
    -- local rightSlavesNumber = math.floor(#cls / 2)
    -- local leftSlavesNumber  = #cls - rightSlavesNumber - 1

    local slavesWidth       = math.floor((wa.width - mstrWidth) / 2)
    local leftSlavesHeight  = math.floor(wa.height / leftSlavesNumber)
    local rightSlavesHeight = math.floor(wa.height / rightSlavesNumber)

    for i = 1, mstrNumber do
        local rowIndex = i - 1

        local c = cls[i]
        local g = {}

        g.height = math.max(mstrHeight, 1)
        g.y = wa.y + mstrHeight * rowIndex

        if mstrFillPolicy == 'expand' and mstrNumber == #cls then
            -- There are only master's
            g.width  = math.max(wa.width, 1)
            g.x = wa.x
        elseif rightSlavesNumber >= 1 and leftSlavesNumber == 0 then
            -- There are masters and right slaves
            g.width  = math.max(mstrWidthFact * wa.width, 1)
            g.x = wa.x
        else
            -- Other cases
            g.width  = math.max(mstrWidthFact * wa.width, 1)
            g.x = wa.x + slavesWidth
        end

        g.width  = math.max(g.width, 1)
        g.height = math.max(g.height, 1)

        p.geometries[c] = g
    end

    -- for i = 2, (1 + leftSlavesNumber) do
    --     rowIndex = i - 2
    for i = (1 + mstrNumber + rightSlavesNumber), #cls do
        local rowIndex = i - (1 + mstrNumber + rightSlavesNumber)

        local c = cls[i]
        local g = {}

        g.width  = slavesWidth
        g.height = math.floor(wa.height / leftSlavesNumber)

        g.x = wa.x
        g.y = wa.y + leftSlavesHeight * rowIndex

        g.width  = math.max(g.width, 1)
        g.height = math.max(g.height, 1)

        p.geometries[c] = g
    end

    -- for i = (2 + leftSlavesNumber), #cls do
    --     rowIndex = i - (2 + leftSlavesNumber)
    for i = mstrNumber + 1, (mstrNumber + rightSlavesNumber) do
        local rowIndex = i - mstrNumber - 1 

        local c = cls[i]
        local g = {}

        g.height = math.floor(wa.height / rightSlavesNumber)

        if leftSlavesNumber == 0 then
            g.width = (1 - mstrWidthFact) * wa.width
            g.x = wa.x + mstrWidth
        else
            g.width = slavesWidth
            g.x = wa.x + slavesWidth + mstrWidth
        end

        g.y = wa.y + rightSlavesHeight * rowIndex

        g.width  = math.max(g.width, 1)
        g.height = math.max(g.height, 1)

        p.geometries[c] = g
    end
end

centermaster.name = "centermaster"

function centermaster.arrange(p)
    return arrange(p)
end

return centermaster
