local Event = require("common.event")
local inspect = require("common.inspect")
local log = require("common.log")
log = log.module("sprs")
local util = require("common.util")

---@class SpriteData
---@field object_id hash
---@field sprite_url url
---@field script_url url
---@field name string
SpriteData = {}

---@class SpritezesData
---@field name string
---@field names string
---@field sprite_list table<number, table<number, SpriteData>>
---@field sprite_map table<string, number>
---@field animation string
---@field compound_fn fun(name, animation): string
SpritezesData = {}

local M = {
    messages = {
        register = hash("register"),
    },
    on_register = Event(),
    ---@type table<string, SpritezesData>
    instances = {},
}

function M.flush()
    M.on_register:flush()
    M.instances = {}
end
function M._delete(spritezes_id, listener)
    M.instances[spritezes_id] = nil
    M.on_register:unsubscribe(listener)
end

function M.register(spritezes_id, names, animation, compound_fn)
    local instance = M.instances[spritezes_id] or {}
    assert(names and #names > 0)
    -- print("print thes is me", spritezes_id)
    M.instances[spritezes_id] = instance
    instance.names = names
    instance.animation = animation
    instance.compound_fn = compound_fn
        or function(name, anim)
            return ("%s_%s"):format(tostring(name), tostring(anim))
        end

    instance.compound_test = instance.compound_fn("test", animation)

    -- msg.post(spritezes_id, M.messages.register)
    M.on_register:invoke({
        spritezes_id = spritezes_id,
        -- names = names,
        -- animation = animation,
    })
end

---@return SpriteData?
function M.get_sprite_data(spritezes_id, name)
    local instance = M.instances[spritezes_id]
    if not instance then
        return
    end

    local layer_index = instance.sprite_map[name]
    local layer = instance.sprite_list[layer_index]
    return layer
end
function M._update(self)
    -- local instance = M.instances[self.own_id]
    -- if instance == nil then
    --     error(("update called on non-existing instance %s"):format(self.own_id))
    -- end
    -- instance.names = self.names
    -- instance.sprite_list = self.sprite_list
    -- instance.sprite_map = self.sprite_map
    -- instance.animation = self.animation
    -- print("empty?")
    -- pprint(instance)
end

---Sets a property on a all spritezes sprites
---@param spritezes_id hash
---@param property string
---@param value unknown
function M.set(spritezes_id, property, value)
    M._apply(spritezes_id, function(sprite_data)
        go.set(sprite_data.sprite_url, property, value)
    end)
end

function M.play_flipbook(spritezes_id, animation_id, complete_function, play_properties)
    M._apply(spritezes_id, function(sprite_data, _, instance)
        sprite.play_flipbook(
            sprite_data.sprite_url,
            instance.compound_fn(sprite_data.name, animation_id),
            complete_function or util.empty_fn,
            play_properties or {}
        )
    end)
end

--- go.animate wrapper
---@param spritezes_id any
---@param property string
---@param playback any
---@param to unknown
---@param easing any
---@param duration number
---@param delay number
---@param complete_function fun()
function M.animate(spritezes_id, property, playback, to, easing, duration, delay, complete_function)
    M._apply(spritezes_id, function(sprite_data)
        go.animate(
            sprite_data.sprite_url,
            property,
            playback,
            to,
            easing,
            duration,
            delay or 0,
            complete_function or util.empty_fn
        )
    end)
end

function M.set_vflip(spritezes_id, flip)
    M._apply(spritezes_id, function(sprite_data)
        sprite.set_vflip(sprite_data.sprite_url, flip)
    end)
end

function M.set_hflip(spritezes_id, flip)
    M._apply(spritezes_id, function(sprite_data)
        sprite.set_hflip(sprite_data.sprite_url, flip)
    end)
end

function M.get_size(spritezes_id)
    local sprite_data = M._first(spritezes_id)
    if not sprite_data then
        return vmath.vector3()
    end
    return go.get(sprite_data.sprite_url, "size")
end

function M._first(spritezes_id)
    local instance = M.instances[spritezes_id]
    assert(instance ~= nil, ("non-existing instance %s, %s"):format(spritezes_id, ""))
    if not instance.sprite_list then
        log:warn("attempted to apply modifier but spritezes hasn't been created.")
        return nil
    end
    return instance.sprite_list[1]
end
function M._apply(spritezes_id, modifier)
    modifier = modifier or util.empty_fn
    local instance = M.instances[spritezes_id]
    assert(instance ~= nil, ("non-existing instance %s, %s"):format(spritezes_id, ""))
    if not instance.sprite_list then
        log:warn("attempted to apply modifier but spritezes hasn't been created.")
        return
    end

    for i, sprite_data in ipairs(instance.sprite_list) do
        modifier(sprite_data, i, instance)
    end
end

function M.release(spritezes_id)
    local spr_obj = M.instances[spritezes_id]
    if not spr_obj then
        return
    end
    M.instances[spritezes_id] = nil
end
return M
