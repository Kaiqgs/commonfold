local _table = require("common._table")
local M = {}

function M.choice(table)
    if #table == 0 then
        return nil
    end
    local index = math.random(1, #table)
    return table[index]
end

function M.choice_except(table, exceptions, comparator)
    local choice = M.choice(table)
    local max_count = 9999
    local counter = 0
    while _table.find(exceptions, choice, comparator) and counter < max_count do
        choice = M.choice(table)
        counter = counter + 1
    end
    if counter >= max_count then
        assert(false, "endless loop detected")
    end
    return choice
end

function M.random()
    return math.random()
end

function M.centerand()
    return M.random() * 2 - 1
end

function M.bool(chance)
    return M.random() < (chance or 0.5)
end

function M.randomr(m, n)
    return math.random(m, n)
end

function M.uvec3()
    return vmath.vector3(M.centerand(), M.centerand(), M.centerand())
end

function M.uvec2()
    return vmath.vector3(M.centerand(), M.centerand(), 0)
end
return M
