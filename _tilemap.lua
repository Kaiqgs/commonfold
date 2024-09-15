local M = {}

function M.tile_to_world(tile_width, tile_height, x, y)
    return vmath.vector3(x * tile_width, y * tile_height, 0)
end
return M
