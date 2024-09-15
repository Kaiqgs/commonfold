local Event = require("common.event")
local util = require("common.util")
local log = require("common.log")
log = log.module("commonet")

---@class CommonNetwork
---@field messages table
---@field ticked Event
---@field connected Event
---@field client_ticked Event
---@field input_queue table
---@field tick number
---@field tick_rate_s number
---@field sanitization_messages table
---@field tick_dif number
---@field on_tick fun(room:table)
---@field on_connect fun(room:table)
---@field on_client_ticked fun(room:table)
---@field on_input fun(inputmsg:any)
---@field set_tick_rate fun(tick_rate:number)
---@field set_sanitization_messages fun(sm:table)
---@field register_message fun(key:string, payload:any)
---@field clear_messages fun()
---@field clear_outsynced_inputs fun(server_tick:number)
local M = {
    messages = {},
    ticked = Event(),
    connected = Event(),
    disconnected = Event(),
    -- Client needs to be manually invoked
    client_ticked = Event(),
    input_queue = {},
    tick = 0,
    tick_rate_s = 20 / 1000,
    ip_address = "216-238-112-127.colyseus.dev",
    ip_prefix = "wss",
    port = 80,--2567,
    tick_stat = 0,
    -- list of messages
    sanitization_messages = {},
    tick_dif = 0,
}
function M.set_ip_adress(ip_address, ip_prefix, port)
    M.ip_address = ip_address
    M.ip_prefix = ip_prefix or M.ip_prefix
    M.port = port or M.port
end
function M.set_tick_rate(tick_rate)
    M.tick_rate_s = tick_rate
end

function M.set_input_queue(input_queue)
    assert(input_queue.cap)
    M.input_queue = input_queue
end

function M.set_sanitization_messages(sm)
    M.sanitization_messages = sm
end
function M.register_message(key, payload)
    M.messages[key] = payload or {}
end

function M.clear_messages()
    M.messages = {}
end

function M.clear_outsynced_inputs(server_tick)
    if server_tick == nil then
        return
    end
    M.input_queue:cap(server_tick)
    -- local start = M.input_queue:size()
    -- while M.input_queue:size() > 0 and M.input_queue:peek().tickReference < (server_tick or 0) do
    --     M.input_queue:pop()
    --     if M.input_queue:size() == 0 then
    --         break
    --     end
    -- end
    -- local input_count = start - M.input_queue:size()
    -- if input_count > 0 then
    --     log:info(string.format("removed %d inputs", input_count))
    -- end
end

function M.on_connect(room)
    M.connected:invoke(room)
end
function M.on_tick(room)
    M.ticked:invoke(room)
end

function M.on_client_ticked(room)
    if not room then
        return
    end
    M.clear_outsynced_inputs(room.state.tick)
    M.client_ticked:invoke(room, M.tick, room.state.tick or 0)
    M.tick = M.tick + 1
    -- log:info(string.format(
    --     "client_t=%d, server_tick=%d    | delta=%d",
    --     M.tick or -999,
    --     room.state.tick or -999,
    --     -- agentobj.tickReference or -999,
    --     M.tick_dif or 999
    -- ))
end

function M.on_disconnected(...)
    M.disconnected:invoke(...)
    M.disconnected:flush()
    M.connected:flush()
    M.ticked:flush()
    M.client_ticked:flush()
    M.messages = {}
    M.input_queue:clear()
    M.tick = 0
end

function M.on_input(input_message)
    assert(input_message.name)
    -- print("input_on", input_message.tickReference)
    local inputs = M.input_queue:get(M.tick) or {
        tickReference = M.tick,
    }
    inputs[input_message.name] = input_message
    M.input_queue:upsert(inputs)
    M.register_message("inputs", inputs)
end

local function test_network()
    print("hey")
    -- debug.debug()
    -- local function test_input_gets_cleaned()
    --     M.on_input({x=1, y=1}, "move")
    --     local mockRoom = {
    --         state = {
    --             tick = 1,
    --             agents = {{
    --
    --             }}
    --         }
    --     }
    --     M.on_client_ticked(mockRoom)
    --     assert(#M.input_queue.list)
    --
    -- end
end

util.run_once("network_test", test_network)

return M
