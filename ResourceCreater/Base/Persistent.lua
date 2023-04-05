local IDManager = require "ResourceCreater.Base.IDManager"
local OrderManager = require "ResourceCreater.Base.OrderManager"
local TableUtils = require "ResourceCreater.Base.TableUtils"


Persistent = {}

local PersistUnit = {}
local PersistItem = {}
local PersistAbility = {}

function Persistent.RegistUnit(unit)
    unit.ID = IDManager.GetUnitID()
    table.insert(PersistUnit, unit)
    return unit.ID
end

function Persistent.RegistHero(unit)
    unit.ID = IDManager.GetHeroID()
    table.insert(PersistUnit, unit)
    return unit.ID
end

function Persistent.RegistItem(item)
    item.ID = IDManager.GetItemID()
    table.insert(PersistItem, item)
    return item.ID
end

-- @flag: 是否是主动技能
local function AbilityParser(ability, flag)
    local levels = ability.levels

    if ability._parent == "ANcl" then
        if flag then
            ability["DataF"] = OrderManager.GetOrder()
        else
            ability["DataF"] = "none"
        end
    end

    for key, value in pairs(ability) do
        if (key == "Tip" or key == "Ubertip") and type(value) == "string" then
            local t = {}
            for i = 1, levels, 1 do
                table.insert(t, "\"" .. value .. "\"")
            end
            ability[key] = t
        elseif string.match(key, "Data[A-F]") then
            if type(value) == "table" and type(value[1]) == "number" then
                local t = {}
                for i = 1, levels, 1 do
                    table.insert(t, value[1] + value[2] * (i - 1))
                end
                ability[key] = t
            elseif type(value) == "string" then
                local t = {}
                for i = 1, levels, 1 do
                    table.insert(t, "\"" .. value .. "\"")
                end
                ability[key] = t
            end
        end
    end

    return ability
end


-- @flag: 是否是主动技能
function Persistent.RegistAbility(ability, flag)
    ability.ID = IDManager.GetAbilityID()
    AbilityParser(ability, flag)
    table.insert(PersistAbility, ability)
    return ability.ID
end

function Persistent.Persist()
    -- region 持久化实体信息
    local file = io.open("./table/ability.ini", "w")
    if file ~= nil then
        for key, value in pairs(PersistAbility) do
            file:write(TableUtils.Serilize(value))
            file:write("\n")
        end
        file:flush()
        file:close()
    end

    local file = io.open("./table/unit.ini", "w")
    if file ~= nil then
        for key, value in pairs(PersistUnit) do
            file:write(TableUtils.Serilize(value))
            file:write("\n")
        end
        file:flush()
        file:close()
    end


    local file = io.open("./table/item.ini", "w")
    if file ~= nil then
        for key, value in pairs(PersistItem) do
            file:write(TableUtils.Serilize(value))
            file:write("\n")
        end
        file:flush()
        file:close()
    end
end
