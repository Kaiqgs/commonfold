local Event = require("common.event")
local pools = {
    play = {},
    stop = {},
    check = {},
}
local M = {
    outline = false,
    ---@type Event
    on_register = Event(),
}

function M.set_outline(outline)
    M.outline = outline
    M.on_register:invoke(outline)
end

function M.register(callback)
    if M.outline then
        callback(M.outline)
    end
    M.on_register:subscribe(callback)
end

function M.play(audio_pool_name, play_properties)
    local evt = pools.play[audio_pool_name]
    if evt == nil then
        print(string.format("warning: no audio_pool named %s to play", tostring(audio_pool_name)))
        return
    end
    evt:invoke(play_properties)
end

function M.play_once(audio_pool_name, play_properties)
    if M.is_playing(audio_pool_name) then
        return
    end
    local evt = pools.play[audio_pool_name]
    if evt == nil then
        print(string.format("warning: no audio_pool named %s to play", tostring(audio_pool_name)))
        return
    end
    evt:invoke(play_properties)
end

function M.stop(audio_pool_name)
    local evt = pools.stop[audio_pool_name]

    if evt == nil then
        print(string.format("warning: no audio_pool named %s to stop", tostring(audio_pool_name)))
        return
    end
    evt:invoke()
end

function M.stop_all()
    for pool_name, _ in pairs(pools.stop) do
        M.stop(pool_name)
    end
end

function M.is_playing(audio_pool_name)
    local evt = pools.check[audio_pool_name]
    if evt == nil then
        print(string.format("warning: no audio_pool named %s to check", tostring(audio_pool_name)))
        return false
    end
    local data = { is_playing = false }
    pools.check[audio_pool_name]:invoke(data)
    return data.is_playing
end

-- script methods
function M.pool_play(name)
    if pools.play[name] == nil then
        pools.play[name] = Event()
    end
    return pools.play[name]
end

function M.pool_stop(name)
    if pools.stop[name] == nil then
        pools.stop[name] = Event()
    end
    return pools.stop[name]
end

function M.pool_check(name)
    if pools.check[name] == nil then
        pools.check[name] = Event()
    end
    return pools.check[name]
end

return M
