local chars = [[0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ]]
local period = string.len(chars)
---根据header与index的不同配制出物品ID
---@param header string 四位ID的前一位或者两位
---@param index integer 后剩余位所属的Index, 从1开始
---@return string
local function GetIDByIndex(header, index)
    local t = {}
    index = index - 1

    repeat
        local mod = index % period
        index = index // period
        table.insert(t, chars:sub(mod + 1, mod + 1))
    until index < period
    table.insert(t, chars:sub(index + 1, index + 1))

    local maxLen = 4 - header:len()

    if #t < maxLen then
        table.insert(t, "0")
    elseif #t > maxLen then
        error("too huge index")
    end

    return header .. string.reverse(table.concat(t))
end

local mt = {}

local abilityCount = 0
function mt.GetAbilityID()
    abilityCount = abilityCount + 1
    local id = GetIDByIndex("A", abilityCount)
    return id
end

local itemCount = 0
function mt.GetItemID()
    itemCount = itemCount + 1
    local id = GetIDByIndex("I", itemCount)
    return id
end

local unitCount = 0
function mt.GetUnitID()
    unitCount = unitCount + 1
    local id = GetIDByIndex("h", unitCount)
    return id
end

function mt.GetHeroID()
    unitCount = unitCount + 1
    local id = GetIDByIndex("H", unitCount)
    return id
end


return mt