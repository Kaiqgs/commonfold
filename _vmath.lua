local M = {}
M.left = function()
    return vmath.vector3(-1, 0, 0)
end

M.right = function()
    return vmath.vector3(1, 0, 0)
end

M.up = function()
    return vmath.vector3(0, 1, 0)
end

M.down = function()
    return vmath.vector3(0, -1, 0)
end

M.one = function()
    return vmath.vector3(1, 1, 1)
end

M.zero = function()
    return vmath.vector3(0, 0, 0)
end

M.sides2d = {
    vmath.vector3(0, 1, 0),
    vmath.vector3(1, 0, 0),
    vmath.vector3(0, -1, 0),
    vmath.vector3(-1, 0, 0),
}


return M
