local nc = require("common.new_class")
---@class Deque
---@field list table
---@field new fun():Deque
---@field push fun(self: Deque, item:any):void
---@field pop fun():any
---@field peek fun():any
M = nc.new_class({})
function M.new(o)
    return nc.new_init(o, M, { list = {} })
end

function M:push(item)
    table.insert(self.list, item)
end

function M:pop()
    if #self.list == 0 then
        return nil
    end
    local item = self.list[1]
    table.remove(self.list, 1)
    return item
end

function M:peek()
    return self.list[1]
end

function M:size()
    return #self.list
end

return M
