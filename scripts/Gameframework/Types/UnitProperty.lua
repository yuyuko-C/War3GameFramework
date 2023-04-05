local helper = require "Gameframework.Types.UnitPropertyHelper"
local UnitPropertySource = require "Gameframework.Types.UnitPropertySource"

local mt = {}
mt.__index = mt
mt.Type = "UnitProperty"
mt._Name = nil
mt._Unit = Types.Unit
mt._Variable = 0
mt._Fixed = UnitPropertySource
mt._FixedValue = 0

local function ApplyVariable(self)
    if helper.Variable[self._Name] ~= nil then
        helper.Variable[self._Name](self._Unit, self._Variable)
    end
end

local function ApplyFixed(self)
    if helper.Fixed[self._Name] ~= nil then
        helper.Fixed[self._Name](self._Unit, self._FixedValue)
    end
end

function mt:SetVariable(value)
    self._Variable = math.min(math.max(0, value), self._FixedValue)
    ApplyVariable(self)
end

function mt:AddVariable(value)
    self._Variable = math.min(math.max(0, self._Variable + value), self._FixedValue)
    ApplyVariable(self)
end

function mt:SetVariablePercent(percent)
    self._Variable = self._FixedValue * percent
    ApplyVariable(self)
end

function mt:SetFixedValue(avatar, skill, buff, item)
    self._Fixed:SetValue(avatar, skill, buff, item)
    self._FixedValue = self._Fixed:Value()
    if self._Variable > self._FixedValue then
        self._Variable = self._FixedValue
    end
    ApplyFixed(self)
end

function mt:AddFixedValue(avatar, skill, buff, item)
    self._Fixed:AddValue(avatar, skill, buff, item)
    self._FixedValue = self._Fixed:Value()
    if self._Variable > self._FixedValue then
        self._Variable = self._FixedValue
    end
    ApplyFixed(self)
end

function mt:Clear()
    self._Name = nil
    self._Unit = nil
    self._Variable = 0
    self._Fixed = nil
    self._FixedValue = 0
end

local Collection = {}
local function PoolGet()
    local count = #Collection
    if count > 0 then
        return table.remove(Collection)
    else
        return setmetatable({}, mt)
    end
end
Yuyuko.RefrencePool[mt.Type] = Collection


function mt.Create(unit, name, avatar, skill, buff, item)
    local property = PoolGet()
    property._Unit = unit
    property._Name = name
    property._Fixed = UnitPropertySource.Create(avatar, skill, buff, item)
    if name == "HPMAX" then
        property._Fixed:SetRange(1, 2 ^ 30)
    elseif name == "MPMAX" then
        property._Fixed:SetRange(1, 2 ^ 30)
    elseif name == "移动速度" then
        -- 高于1500会有明显的bug情况
        property._Fixed:SetRange(0, 1500)
    elseif name == "攻击间隔" then
        -- 游戏实际最小攻击间隔0.1
        property._Fixed:SetRange(0.1, 5)
    elseif name == "攻击速度" then
        -- 游戏实际最大攻击速度500
        property._Fixed:SetRange(0, 500)
    elseif name == "攻击范围" then
        property._Fixed:SetRange(0, 3000)
    else
        property._Fixed:SetRange(-2 ^ 30, 2 ^ 30)
    end

    property._FixedValue = property._Fixed:Value()
    ApplyFixed(property)
    return property
end

return mt
