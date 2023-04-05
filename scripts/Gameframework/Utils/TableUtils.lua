local mt = {}

local function copy_table(from, to)
    if type(from) ~= "table" then return end

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

function mt.Serialize(obj)
    local text = ""
    local t = type(obj)
    if t == "number" then
        text = text .. obj
    elseif t == "boolean" then
        text = text .. tostring(obj)
    elseif t == "string" then
        text = text .. string.format("%q", obj)
    elseif t == "table" then
        text = text .. "{\n"

        for k, v in pairs(obj) do
            text = text .. "[" .. mt.Serialize(k) .. "]=" .. mt.Serialize(v) .. ",\n"
        end

        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                text = text .. "[" .. mt.Serialize(k) .. "]=" .. mt.Serialize(v) .. ",\n"
            end
        end

        text = text .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end

    return text
end

function mt.Deserialize(text)
    local t = type(text)
    if t == "nil" or text == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        text = tostring(text)
    else
        error("can not unserialize a " .. t .. " type.")
    end

    text = "return " .. text

    local func = load(text)
    if func == nil then return nil end
    return func()
end

return mt
