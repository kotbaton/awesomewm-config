local math = math
local screen = screen

--[[
--  Stack right layout:
--  +-------+------+
--  |       |      |
--  |   1   | 2... |
--  |       |      |
--  +-------+------+
--
--  Stack left layout:
--  +------+-------+
--  |      |       |
--  | 2... |   1   |
--  |      |       |
--  +------+-------+
--]]

local stack = {}

local function arrange(p, dir)
    local t   = p.tag or screen[p.screen].selected_tag
    local wa  = p.workarea
    local cls = p.clients

    if #cls == 0 then return end

    local mstrWidthFact     = t.master_width_factor

    local mstrWidth         = math.floor(wa.width * mstrWidthFact)
    local mstrHeight        = math.floor(wa.height)

    local slavesNumber      = #cls - 1
    local slavesWidth       = math.floor(wa.width - mstrWidth)
    local slavesHeight      = math.floor(wa.height)

    if slavesNumber == 0 then
        mstrWidth = wa.width
    end
    -- Places master
    local c, g = cls[1], {}

    g.height = math.max(mstrHeight, 1)
    g.width  = math.max(mstrWidth,  1)

    g.y = wa.y
    g.x = (dir == 'right') and (wa.x) or (wa.x + slavesWidth)
    if slavesNumber == 0 then
        g.x = wa.x
    end

    p.geometries[c] = g

    if #cls == 1 then return end

    -- Places slaves
    for i = 2, #cls do
        local c, g = cls[i], {}

        g.height = math.max(slavesHeight, 1)
        g.width  = math.max(slavesWidth,  1)

        g.y = wa.y
        g.x = (dir == 'right') and (wa.x + mstrWidth) or (wa.x)

        p.geometries[c] = g
    end
end

stack.name = "stack"
function stack.arrange(p)
    return arrange(p, 'right')
end

stack.left = {}
stack.left.name = "stackLeft"
function stack.left.arrange(p)
    return arrange(p, 'left')
end

return stack
