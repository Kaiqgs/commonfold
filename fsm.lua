local _stateCounter = 0
local _table = require("common._table")
local fsb = require("common.fsb")
local util = require("common.util")
local function emptyFunc(...) end
local function Contains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end
local printout = true
local FiniteState = util.NewClass({})
local FiniteStateMachine = util.NewClass({})
function FiniteState.new(o)
    _stateCounter = _stateCounter + 1
    o = o or {}
    ---@class FiniteState
    ---@field context any
    ---@field name string
    ---@field done boolean
    ---@field enter function
    ---@field exit function
    ---@field predicate function(self, ...): boolean
    ---@field update function(self, dt): void
    local new = {
        name = o.name or tostring(_stateCounter),
        context = nil,
        predicate_to = o.predicate_to or {},
        done = o.done or false,
    }
    local unreplaceable = { "name", "context", "enter", "exit", "predicate", "update" }
    for k, v in pairs(o) do
        if not Contains(unreplaceable, k) then
            new[k] = v
        end
    end
    local self = setmetatable(new, FiniteState)
    self.__index = self
    function self:enter(...)
        self.done = o.done or false;
        (o.enter or emptyFunc)(self, ...)
        self.context = ...
    end

    function self:exit(...)
        (o.exit or emptyFunc)(self, ...)
        local ctx = self.context
        self.context = nil
        return ctx
    end

    function self:update(...)
        (o.update or emptyFunc)(self, ...)
    end

    ---@return boolean
    function self:predicate(otherstate, ...)
        -- return o.done or not o.predicate or (o.predicate and o.predicate(self, ...))
        local predicate_to = self.predicate_to[otherstate.name]
                and self.predicate_to[otherstate.name](self, otherstate, ...)
            or false
        return self.done or (o.predicate or emptyFunc)(self, otherstate, ...) or predicate_to
    end

    return self
end

function FiniteStateMachine.new(o)
    o = o or {}
    local states = {}
    local counter = 0
    for _, v in pairs(o.states or {}) do
        states[v.name] = v
        counter = counter +1
    end
    assert(counter > 0, "missing states")

    local self = setmetatable(
        ---@class FiniteStateMachine
        ---@field states table<string, FiniteState>
        ---@field state FiniteState
        ---@field transitions table<string, table<string, boolean>>
        {
            states = states,
            state = nil,
            transitions = o.transitions or {},
        },
        FiniteStateMachine
    )
    self.__index = self
    return self
end

---Adds transition
---@param state_a FiniteState
---@param state_b FiniteState
---@return boolean
function FiniteStateMachine:transition(state_a, state_b)
    -- self.transitions =
    self.transitions[state_a.name] = self.transitions[state_a.name] or {}
    self.transitions[state_a.name][state_b.name] = true
    return self
end

---Set initial state
---@param state FiniteState
function FiniteStateMachine:start(state, context, ...)
    assert(self.state == nil)
    assert(state ~= nil)
    assert(type(state) ~= "string", "string not valid, did you mean the name of the state?")
    self.state = state
    self.state:enter(context or {}, ...)
    return self
end

function FiniteStateMachine:update(...)
    self.state:update(...)
    for name_b, _ in pairs(self.transitions[self.state.name] or {}) do
        local otherstate = self.states[name_b]
        if otherstate then
            if self.state:predicate(otherstate) then
                local laststate = self.state
                local ctx = laststate:exit()
                self.state = otherstate
                self.state:enter(ctx, ...)
                break
            end
        end
    end
end

function FiniteStateMachine:set_context(context)
    local state = self.state or {}
    state.context = context
end

local function _moduleAssert()
    -- Semaphore
    local states = {
        red = FiniteState({
            name = "red",
            -- done = true,
            predicate = function(self, otherstate)
                assert(otherstate ~= nil, "predicate to nothing")
                return true
            end,
        }),
        yellow = FiniteState({
            name = "yellow",
            -- done = true,
            predicate = function(self, otherstate)
                assert(otherstate ~= nil, "predicate to nothing")
                return true
            end,
        }),
        green = FiniteState({
            name = "green",
            done = true,
            predicate = function(self, otherstate)
                print("my otherstate==", otherstate)
                assert(otherstate ~= nil, "predicate to nothing")
            end,
        }),
    }
    local fsm = FiniteStateMachine({
            states = states,
        })
        :transition(states.green, states.yellow)
        :transition(states.yellow, states.red)
        :transition(states.red, states.green)
        :start(states.green, { chickencrossing = true })

    assert(fsm.state.name == states.green.name, "Bad initialization")
    assert(fsm.state.context.chickencrossing, "Invalid context movement")
    fsm:update()
    assert(fsm.state.context.chickencrossing, "Invalid context movement")
    assert(fsm.state.name == states.yellow.name, "Bad transition = " .. fsm.state.name)
    fsm:update()
    assert(fsm.state.context.chickencrossing, "Invalid context movement")
    assert(fsm.state.name == states.red.name, "Bad transition = " .. fsm.state.name)
    fsm:update()
    assert(fsm.state.context.chickencrossing, "Invalid context movement")
    assert(fsm.state.name == states.green.name, "Bad transition = " .. fsm.state.name)
end

local function _fsbAssert()
    local s = {
        idle = "idle",
        walk = "walk",
        run = "run",
    }
    local states = {
        idle = fsb.FiniteStateBuilder()
            :name(s.idle)
            :predicate_to(s.walk, function(self, _, ...)
                return self.context.speed > 0 and self.context.speed < 50
            end)
            :predicate_to(s.run, function(self, _, ...)
                return self.context.speed >= 50
            end)
            :build(),
        walk = fsb.FiniteStateBuilder()
            :name(s.walk)
            :predicate_to(s.run, function(self, _, ...)
                return self.context.speed >= 50
            end)
            :predicate_to(s.idle, function(self, _, ...)
                return self.context.speed == 0
            end)
            :build(),
        run = fsb.FiniteStateBuilder()
            :name(s.run)
            :predicate_to(s.walk, function(self, _, ...)
                return self.context.speed < 50
            end)
            :predicate_to(s.idle, function(self, _, ...)
                return self.context.speed == 0
            end)
            :build(),
    }
    local fsm = FiniteStateMachine({
            states = states,
        })
        :transition(states.idle, states.walk)
        :transition(states.idle, states.run)
        :transition(states.walk, states.run)
        :transition(states.walk, states.idle)
        :transition(states.run, states.idle)
        :transition(states.run, states.walk)
        :start(states.idle, { speed = 0 })

    fsm:set_context({ speed = 0 })
    fsm:update()
    assert(fsm.state.name == s.idle)
    fsm:set_context({ speed = 10 })
    fsm:update()
    assert(fsm.state.name == s.walk)
    fsm:set_context({ speed = 60 })
    fsm:update()
    assert(fsm.state.name == s.run)
    fsm:set_context({ speed = 50 })
    fsm:update()
    assert(fsm.state.name == s.run)
    fsm:set_context({ speed = 49 })
    fsm:update()
    assert(fsm.state.name == s.walk)
    fsm:set_context({ speed = 10 })
    fsm:update()
    assert(fsm.state.name == s.walk)
    fsm:set_context({ speed = 0 })
    fsm:update()
    assert(fsm.state.name == s.idle)
end

_fsbAssert()
_moduleAssert()

return {
    FiniteState = FiniteState,
    FiniteStateMachine = FiniteStateMachine,
    NilName = "__DefinitelyNotAStateName__",
}
