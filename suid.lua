local M = {
    format = "xxxxxx",
    catalog = {},
}

function M._rnd()
    local random = math.random
    return string.gsub(M.format, "[xy]", function(c)
        local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
        return string.format("%x", v)
    end)
end

function M.rnd()
    local result = M._rnd()
    for _ = 1, 999 do
        if M.catalog[result] == nil then
            break
        end
        result = M._rnd()
    end
    M.catalog[result] = true
    -- pprint(M.catalog)
    -- pprint("fucking catalog above")
    return result
end
return M
