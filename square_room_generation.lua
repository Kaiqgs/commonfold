local util = require("common.util")
local M = {}

local sides = {
    vmath.vector3(0, 1, 0),
    vmath.vector3(1, 0, 0),
    vmath.vector3(0, -1, 0),
    vmath.vector3(-1, 0, 0),
}

M.sides = sides

local function inbound(gridsize, position)
    return position.x > 0
        and position.y > 0
        and position.x <= gridsize
        and position.y <= gridsize
end

function M.pos2idx(position)
    if position.x == 0 then
        position.x = math.abs(position.x)
    end
    if position.y == 0 then
        position.y = math.abs(position.y)
    end
    return math.floor(position.x) .. "_" .. math.floor(position.y)
end

---@param idx string
function M.idx2pos(idx)
    local t = {}
    for k, _ in string.gmatch(idx, "-?%d*") do
        if k ~= "" then
            table.insert(t, tonumber(k))
        end
    end

    -- print(t, "here")
    -- pprint(t)
    return vmath.vector3(t[1], t[2], 0)
end

function M.distance(idx1, idx2)
    local vec1 = M.idx2pos(idx1)
    local vec2 = M.idx2pos(idx2)
    local distance = vmath.length(vec1 - vec2)
    -- print(idx1, idx2)
    -- print(vec1, vec2)
    return distance or 0
end

function M.generate(n, gridsize)
    local posx = math.random(gridsize)
    local posy = math.random(gridsize)
    local initial_position = vmath.vector3(posx, posy, 0)

    local counter = 1
    local itercount = 0
    local maxiter = 999

    local connection = {}
    local nextrooms = {
        initial_position,
    }
    local created = {
        [M.pos2idx(initial_position)] = true,
    }
    local last_idx

    while counter < n and itercount < maxiter and #nextrooms > 0 do
        local currentpos = table.remove(nextrooms)
        for _, side in ipairs(sides) do
            local notskip = math.random() < 0.5
            local nextpos = currentpos + side
            if notskip and inbound(gridsize, nextpos) then
                connection[M.pos2idx(currentpos)] = connection[M.pos2idx(
                    currentpos
                )] or {}
                connection[M.pos2idx(currentpos)][M.pos2idx(side)] = nextpos

                connection[M.pos2idx(nextpos)] = connection[M.pos2idx(nextpos)]
                    or {}
                connection[M.pos2idx(nextpos)][M.pos2idx(-side)] = currentpos

                local next_idx = M.pos2idx(nextpos)
                if not created[next_idx] then
                    table.insert(nextrooms, nextpos)
                    created[next_idx] = true
                    last_idx = next_idx
                    counter = counter + 1
                end
            end
        end
        itercount = itercount + 1
    end

    local sum = vmath.vector3()
    for k, _ in pairs(created) do
        sum = sum + M.idx2pos(k)
    end
    local center = vmath.vector3(
        math.floor(sum.x / counter),
        math.floor(sum.y / counter),
        math.floor(sum.z / counter)
    )

    -- for room_id, neighbor in pairs(connection) do
    --
    -- end

    return {
        connection = connection,
        counter = counter,
        gridsize = gridsize,
        rooms = created,
        center = center,
        last_room = last_idx,
    }
end

return M
