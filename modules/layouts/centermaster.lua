local math = math
local screen = screen

local centermaster = {}

local function arrange(p)
    local t   = p.tag or screen[p.screen].selected_tag
    local wa  = p.workarea
    local cls = p.clients

    if #cls == 0 then return end

    local mstrWidthFact     = t.master_width_factor

    local mstrWidth         = math.floor(wa.width * mstrWidthFact)
    local mstrHeight        = math.floor(wa.height)

    local leftSlavesNumber  = math.floor(#cls / 2)
    local rightSlavesNumber = #cls - leftSlavesNumber - 1

    local slavesWidth       = math.floor((wa.width - mstrWidth) / 2)
    local leftSlavesHeight  = math.floor(wa.height / leftSlavesNumber)
    local rigthSlavesHeight = math.floor(wa.height / rightSlavesNumber)

    local c = cls[1]
    local g = {}

    g.height = math.max(mstrHeight, 1)
    g.width  = math.max(mstrWidthFact * wa.width, 1)

    g.y = wa.y
    g.x = wa.x + slavesWidth

    p.geometries[c] = g

    if #cls <= 1 then return end

    for i = 2, #cls do
        local rowIndex = math.floor(i / 2) - 1
        local c = cls[i]
        local g = {}

        if i % 2 == 0 then
            -- For left slave
            g.width  = slavesWidth
            g.height = math.floor(wa.height / leftSlavesNumber)

            g.x = wa.x
            g.y = wa.y + leftSlavesHeight * rowIndex
        else
            -- For right slave
            g.width  = slavesWidth
            g.height = math.floor(wa.height / rightSlavesNumber)

            g.x = wa.x + slavesWidth + mstrWidth
            g.y = wa.y + rigthSlavesHeight * rowIndex
        end

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
