local _stateCounter = 0
local util = require("common.util")
---@type FiniteStateBuilder
local FSB = util.NewClass({})

local FS = util.NewClass({})
local M = {

    ---@type FiniteStateBuilder
    FiniteStateBuilder = FSB,
}

function FS.new(o)
    o = o or {}
    o = {
        name = o.name or _stateCounter,
        context = nil,
        done = false,
        predicate_to = {},
        _enter = util.empty_fn,
        _exit = util.empty_fn,
        _update = util.empty_fn,
        _predicate = util.empty_fn,
    }
    _stateCounter = _stateCounter + 1
    local self = setmetatable(o, FS)
    self.__index = self
    return self
end
function FS:enter(...)
    self.done = self.done or false
    self.context = ...
    self:_enter(...)
end
function FS:exit(...)
    self:_exit(...)
    local ctx = self.context
    self.context = nil
    return ctx
end

function FS:update(...)
    -- self.context = ... or self.context
    self:_update(...)
end

function FS:predicate(otherstate, ...)
    -- return self.done or not self.predicate or (self.predicate and self.predicate(self, ...))
    local predicate_to = self.predicate_to[otherstate.name]
            and self.predicate_to[otherstate.name](self, otherstate, ...)
        or false
    return self.done or not not self:_predicate(...) or predicate_to
end

function FSB.new(name)
    local self = setmetatable({}, FSB)
    self = self.__index
    self.data = FS()
    self.data.name = name or self.data.name
    return self
end

function FSB:done(value)
    self.data.done = value or true
    return self
end

function FSB:name(value)
    -- pprint(self)
    self.data.name = value
    return self
end
function FSB:update(func)
    self.data._update = func
    return self
end

function FSB:enter(func)
    self.data._enter = func
    return self
end

function FSB:exit(func)
    self.data._exit = func
    return self
end

function FSB:predicate(func)
    self.data._predicate = func
    return self
end

function FSB:predicate_to(otherstate, func)
    local otherstatename = type(otherstate) == "string" and otherstate or otherstate.name
    self.data.predicate_to[otherstatename] = func
    return self
end

function FSB:build()
    return self.data
end
return M
