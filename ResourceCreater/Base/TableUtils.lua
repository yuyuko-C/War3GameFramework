local mt = {}

---comment
---@param from table
---@param to table
---@return table
local function copy_table(from, to)
    if type(from) ~= "table" then return nil end

    for key, value in pairs(from) do
        local value_type = type(value)

        if value_type == "table" then
            if value ~= from then
                to[key] = {}
                copy_table(value, to[key])
            end
        else
            to[key] = value
        end
    end
    return to
end

function mt.DeepCopy(from) return copy_table(from, {}) end

local function KeyValuePairSerializer(key, value)
    local line
    if type(value) == "string" then
        if (string.find(value, '\\')) then
            line = ("%s = [[%s]]"):format(key, value)
        else
            line = ("%s = \"%s\""):format(key, value)
        end
    elseif type(value) == "number" then
        line = key .. " = " .. value
    elseif type(value) == "table" then
        line = key .. " = " .. "{\n"
        for index, subvalue in ipairs(value) do
            line = line .. index .. " = " .. subvalue .. ",\n"
        end
        line = line .. "}"
    else
        error("expected string, got " .. type(value))
    end
    return line
end



---输出为ini文件
---@param Table table
---@return string
function mt.Serilize(Table)
    local id = '[' .. Table.ID .. ']'
    local content = ""
    for key, value in pairs(Table) do
        if key ~= "ID" then
            content = content .. KeyValuePairSerializer(key, value) .. '\n'
        end
    end
    return id .. '\n' .. content
end

return mt
