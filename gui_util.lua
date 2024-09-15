local M = {}

--- @param extra_node ExtraNode
--- @param animation_id string
function M.flipbook_on_hover(extra_node, animation_id)
    extra_node.on_hover:subscribe(function()
        extra_node:apply(function(node)
            gui.play_flipbook(node, animation_id)
        end)
    end)
    local function _unhover()
        extra_node:apply(function(node)
            gui.cancel_flipbook(node)
            gui.set_flipbook_cursor(node, 0.0)
        end)
    end
    extra_node.on_unhover:subscribe(_unhover)
    _unhover()
end

return M
