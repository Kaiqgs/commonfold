local M = {}
function M.new_class(typetbl)
    typetbl.__index = typetbl
    setmetatable(typetbl, {
        __call = function(cls, ...)
            return cls.new(...)
        end,
    })
    return typetbl
end
local function shallow_copy(table)
    local copy = {}
    for k, v in pairs(table) do
        copy[k] = v
    end
    return copy
end

---@param o table | nil
---@param typeobj table
---@param default table | nil
function M.new_init(o, typeobj, default)
    local defcpy = shallow_copy(default)
    o = o or {}
    for k, v in pairs(defcpy) do
        o[k] = o[k] or v
    end

    local self = setmetatable(o, typeobj)
    self.__index = self
    return self
end

function M.new_init_fn(typeobj, default)
    return function(o)
        return M.new_init(o, typeobj, default)
    end
end

return M
