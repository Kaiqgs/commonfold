---@type CommonGui
local M = {
    default_shadow_offset = vmath.vector3(1, -1, 0),
    default_shadow_color = vmath.vector4(0, 0, 0, 1),
    default_click_offset = vmath.vector3(1, -1, 0),
}
local util = require("common.util")
local Event = require("common.event")
local audio = require("common.audio")

local function node_shadow(node, parent, color, offset, layer)
    local shadoweePos = gui.get_position(node)
    local shadow = gui.clone(node)
    gui.set_inherit_alpha(shadow, false)
    gui.set_parent(shadow, parent)
    gui.move_below(shadow, node)
    gui.set_layer(shadow, layer)
    gui.set_color(shadow, color)
    gui.set_position(shadow, shadoweePos + offset)
    return shadow
end

--- @type ExtraNode
local ExtraNode = util.NewClass({})

function ExtraNode.new(node_id, layer, shadowColor, offset)
    assert(node_id, "node_id is nil")

    -- shadow related
    shadowColor = shadowColor or M.default_shadow_color
    offset = offset or M.default_shadow_offset

    local node = gui.get_node(node_id)
    local parent = gui.get_parent(node)

    local new = {
        node = node,
        parent = parent,
        shadow = node_shadow(node, parent, shadowColor, offset, layer),
        on_press = Event(),
        on_release = Event(),
        on_hover = Event(),
        on_unhover = Event(),
    }
    local self = setmetatable(new, ExtraNode)
    self.__index = self
    return self
end

function ExtraNode:is_enabled()
    return gui.is_enabled(self.node, true) and gui.is_enabled(self.shadow, true)
end

function ExtraNode:on_button_press(action)
    if not self:is_enabled() then
        return
    end
    local touching = gui.pick_node(self.node, action.x, action.y)
    if action.released and self.pressed then
        self.pressed = false
        gui.set_position(self.node, gui.get_position(self.node) - M.default_click_offset)
        self.on_release:invoke(action)
    end
    if not touching then
        return
    end
    if action.pressed and not self.pressed then
        audio.play("blip")

        self.pressed = true
        gui.set_position(self.node, gui.get_position(self.node) + M.default_click_offset)
        self.on_press:invoke(action)
    end
    -- print(string.format("pressed %s, released %s, repeated %s", action.pressed, action.released, action.repeated))
end

function ExtraNode:on_button_hover(action)
    if not self:is_enabled() then
        return
    end
    local touching = gui.pick_node(self.node, action.x, action.y)
    if not touching and self.hovered then
        self.hovered = false
        self.on_unhover:invoke(action)
        print("unhover | hover out")
    elseif touching and not self.hovered then
        self.hovered = true
        self.on_hover:invoke(action)
        print("hover | hover in")
    end
end

function ExtraNode:set_text(value)
    self:apply(function(node)
        gui.set_text(node, value)
    end)
end

function ExtraNode:animate_text(value, delay, base_str)
    delay = delay or 0.1
    base_str = base_str or ""
    for i = 1, #value do
        timer.delay(delay * i, false, function()
            base_str = base_str .. value:sub(i, i)
            self:set_text(base_str)
            audio.play("type")
        end)
    end
    return delay * #value
end

function ExtraNode:set_alpha(value)
    self:apply(function(node)
        gui.set_alpha(node, value)
    end)
end

function ExtraNode:set_enabled(value)
    self:apply(function(node)
        gui.set_enabled(node, value)
    end)
end

function ExtraNode:apply(modifier)
    modifier(self.node)
    modifier(self.shadow)
end

function ExtraNode:set_position(position)
    gui.set_position(self.node, position)
    gui.set_position(self.shadow, position + M.default_shadow_offset)
end

function ExtraNode:animate_position(position, easing, duration, delay, complete_function)
    gui.animate(self.node, "position", position, easing, duration, delay, complete_function)
    gui.animate(self.shadow, "position", position + M.default_shadow_offset, easing, duration, delay)
end

function ExtraNode:play_flipbook(animation, complete_function, play_properties)
    gui.play_flipbook(self.node, animation, complete_function, play_properties or {})
    gui.play_flipbook(self.shadow, animation, function() end, play_properties or {})
end

function ExtraNode:typewrite(text, interval_s, callback, complete_function)
    callback = callback or util.empty_fn
    complete_function = complete_function or util.empty_fn
    interval_s = interval_s or 0.1

    local handles = {}
    local data = { fastforward = false }
    for i = 1, #text do
        handles[i] = timer.delay(interval_s * i, false, function()
            if data.fastforward then
                return
            end
            callback(data)
            if data.fastforward then
                for k, v in pairs(handles) do
                    timer.cancel(v)
                end
                complete_function()
                return
            end
            self:set_text(text:sub(1, i))
        end)
    end
    handles[#handles + 1] = timer.delay(#text * interval_s, false, function()
        if data.fastforward then
            return
        end
        complete_function()
    end)

    local function _cancel()
        data.fastforward = true
    end
    return _cancel
end

M.addShadow = node_shadow
M.ExtraNode = ExtraNode

---@param node_ids any
---@param layer string
---@param shadowColor any
---@return table<string, ExtraNode>
function M.extrafy(node_ids, layer, shadowColor, offset)
    for node_id, _ in pairs(node_ids) do
        node_ids[node_id] = ExtraNode(node_id, layer, shadowColor, offset)
    end
    return node_ids
end

---@return function
function M.on_input_touch(nodes_list)
    return function(_, _, action)
        for _, nodes in ipairs(nodes_list) do
            for _, node in pairs(nodes) do
                node:on_button_press(action)
            end
        end
    end
end

function M.on_input_hover(nodes_list)
    return function(_, _, action)
        for _, nodes in ipairs(nodes_list) do
            for _, node in pairs(nodes) do
                node:on_button_hover(action)
            end
        end
    end
end

M.empty_node = {}
---@cast M.empty_node ExtraNode

return M
