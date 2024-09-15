-- this can and will eventually overflow
local util = require("common.util")

---@class Event
local M = util.NewClass({})
function M.new()
    local self = setmetatable({ listeners = {}, counter = 0 }, M)
    return self
end

---@param callback function
function M:subscribe(callback)
    self.counter = self.counter + 1
    table.insert(
        self.listeners,
        ---@type EventListener
        {
            id = self.counter,
            callback = function(...)
                callback(...)
            end,
        }
    )
    return self.counter
end

---@param id integer
function M:unsubscribe(id)
    for i, listener in ipairs(self.listeners) do
        if listener.id == id then
            table.remove(self.listeners, i)
            return true
        end
    end
    return false
end

function M:flush()
    self.listeners = {}
end

function M:invoke(...)
    for _, listener in ipairs(self.listeners) do
        listener.callback(...)
    end
end

local function _moduleAssert()
    local set_test = {}
    local n = 10
    local test = M()
    local ids = {}
    for i in util.irange(n) do
        local ith_id = test:subscribe(function()
            table.insert(set_test, i)
        end)
        table.insert(ids, ith_id)
    end
    test:invoke()
    assert(#set_test == n)

    for _, id in ipairs(ids) do
        assert(test:unsubscribe(id))
    end
end
_moduleAssert()

---@type Event
return M
