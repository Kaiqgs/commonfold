local Event = require("common.event")
local M = {
    animate_queue = {},
    set_queue = {},
}

function M.animate(property, playback, to, easing, duratin, delay, complete_function)
    table.insert(M.animate_queue, { property, playback, to, easing, duratin, delay, complete_function })
end

function M.set(property, value)
    table.insert(M.set_queue, { property, value })
end

return M
