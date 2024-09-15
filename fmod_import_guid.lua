local inspect = require("common.inspect")
local M = {}

local file_template = [[
local M = %s
return M
]]
local file_pattern = "{([%a%d-]-)}%s([%a]*):([%a%d%p]+)"
local path_pattern = "([^/]+)"
function M.import(opts)
    print(inspect(opts))
    path = "." .. editor.get(opts.selection, "path")
    print("path is", path)
    local file = io.open(path, "r")
    if not file then
        error("error reading file")
    end
    local file_data = file:read("*a")
    file:close()
    print(file_data)

    local data = {}
    local event_outline = {}
    for id, ftype, fpath in file_data:gmatch(file_pattern) do
        -- print(("`%s` `%s` `%s`"):format(id, ftype, fpath))
        data[ftype] = data[ftype] or {}
        local data_type = data[ftype]
        local pointer = ""
        -- data[data_pointer] = data[data_pointer] or {}
        for sub_path in fpath:gmatch(path_pattern) do
            pointer = sub_path
            data_type[pointer] = data_type[pointer] or {}
        end
        data_type[pointer] = { id = id, name = pointer, path = fpath }
        if ftype == "event" then
            event_outline[pointer] = pointer
        end
    end
    data.outline = event_outline

    print(inspect(data))

    local out_file = io.open("./assets/fmod_guid.lua", "w+")
    if not out_file then
        error("error writiting file")
    end
    out_file:write(file_template:format(inspect(data)))
    out_file:flush()
    out_file:close()
    -- print(file_data)
end
return M
