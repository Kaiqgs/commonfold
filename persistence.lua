local M = { registry = {} }

---@class Register
---@field path string
---@field data table
---@field loaded bool
local Register = {}

function M.set_application_id(id)
    M.app_id = id
end

---@return Register
function M.get_register(save_file)
    assert(M.app_id ~= nil, "not initialized")
    if M.registry[save_file] == nil then
        M.registry[save_file] = {
            path = sys.get_save_file(M.app_id, save_file),
            data = {},
        }
    end
    -- local register = M.registry[save_file]

    return M.registry[save_file]
end

function M.load(save_file)
    local register = M.get_register(save_file)
    if sys.exists(register.path) then
        register.data = sys.load(register.path)
        register.loaded = true
    end
    return register
end

function M.save(save_file)
    local register = M.get_register(save_file)
    register.loaded = false
    sys.save(register.path, register.data)
end

function M.set(save_file, key, value, clean)
    local register = M.get_register(save_file)
    register.data[key] = value
    if not clean then
        M.save(save_file)
    end
end

function M.get(save_file, key, default)
    local register = M.get_register(save_file)
    return register.data[key] or default
end

function M.clear(save_file)
    M.registry[save_file] = nil
    local register = M.get_register(save_file)
    sys.save(register.path, register.data)
    return register
end

return M
