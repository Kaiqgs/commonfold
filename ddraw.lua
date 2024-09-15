local camera = require("orthographic.camera")
local M = {
    disabled = false,
}
function M.line(from, to, color)
    if M.disabled then
        return
    end
    msg.post(
        "@render:",
        "draw_line",
        { start_point = from, end_point = to, color = color or vmath.vector4(1, 0, 0, 1) }
    )
end

function M.debug_text(text, position, color)
    if M.disabled then
        return
    end
    msg.post("@render:", "draw_debug_text", {
        text = text,
        position = position,
        color = color or vmath.vector4(1, 0, 0, 1),
    })
end
function M.debug_text_world(text, position, color, camera_id)
    if M.disabled then
        return
    end
    local screen_position = camera.world_to_screen(camera_id, position)
    local x, y = screen_position.x, screen_position.y
    local dwidth, dheight = camera.get_display_size()
    local width, height = camera.get_window_size()
    M.debug_text(text, vmath.vector3(x / dwidth * width, y / dheight * height, 0), color)
end

return M
