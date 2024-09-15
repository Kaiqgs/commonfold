local log = require("common.log")
local M = {}
log = log.module("msg")

M.empty_alias = "empty"
function M.on_message_map(message_mapping)
    local function on_message(self, message_id, message, sender)
        local action = message_mapping[message_id or M.empty_alias]
        if action then
            action(self, message_id, message, sender)
        elseif action ~= false then
            local wrn_msg = string.format(
                "%s have unhandled message of id: %s from %s",
                tostring(msg.url()),
                tostring(message_id),
                tostring(sender)
            )
            log:warn(wrn_msg)
        end
    end
    return on_message
end

function M.on_input_map(input_mapping)
    local function on_input(self, action_id, action)
        local func = input_mapping[action_id or M.empty_alias]
        if func then
            func(self, action_id, action)
        elseif action ~= false and sys.get_engine_info().debug then
            local wrn_msg = string.format("%s did not handle input of id: %s", tostring(msg.url()), tostring(action_id))
            log:warn(wrn_msg)
        end
    end
    return on_input
end

return M
