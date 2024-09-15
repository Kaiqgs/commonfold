local nc = require("common.new_class")
local matching = nil
local general_priority = 0

local Logger = nc.new_class({})
function Logger.new(namespace)
    --- @class Logger
    --- @field namespace string
    --- @field debug fun(...)
    --- @field info fun(...)
    --- @field warn fun(...)
    --- @field error fun(...)
    --- @field trace fun(...)
    local self = setmetatable({ namespace = namespace, loglevel = 1 }, Logger)
    self.__index = self
    return self
end

function Logger:_meta(metaname)
    local priority = general_priority
    general_priority = general_priority + 1
    self[metaname] = function(this, ...)
        -- if matching == nil then
        if priority >= this.loglevel then
            local namespace = this.namespace and (this.namespace) or ""
            print(string.format("%s[%s] ", namespace, metaname), ...)
        end
        -- elseif matching ~= nil then
        --     --TODO: add string matching and level filter
        --     assert(false, "not implemented")
        -- end
    end
end

Logger:_meta("trace")
Logger:_meta("info")
Logger:_meta("debug")
Logger:_meta("warn")
Logger:_meta("error")

---@type Logger
local M = Logger()

---Creates a logger at module level
---@param name string
---@return Logger
function M.module(name)
    return Logger(name)
end

return M
