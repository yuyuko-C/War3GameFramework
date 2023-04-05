local jass = require 'jass.common'
local japi = require 'jass.japi'
local dbg = require 'jass.debug'


local mt = {}
mt.__index = mt
mt.Type = "Effect"
mt._Handle = 0
mt._Center = Types.Point
mt._Center = nil
mt._Unit = Types.Unit
mt._Unit = nil

function mt:Center()
    if self._Unit then
        return self._Unit:Center()
    else
        return self._Center
    end
end

function mt:SetCenter(x, y)
    if not self._Unit then
        self._Center._X = x
        self._Center._Y = y
        japi.EXSetEffectXY(self._Handle, x, y)
    end
end

function mt:SetSize(size)
    japi.EXSetEffectSize(self._Handle, size)
end

function mt:SetHeight(height)
    if not self._Unit then
        self._Center._Z = height
        japi.EXSetEffectZ(self._Handle, height)
    end
end

function mt:Clear()
    jass.DestroyEffect(self._Handle)
    self._Handle = 0

    if not self._Unit then
        Yuyuko.RefrencePool.Push(self._Center)
    else
        self._Unit = nil
    end
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

function mt.PointEffect(modelName, x, y)
    local handle = jass.AddSpecialEffect(modelName, x, y)
    print("handle",handle)
    local effect = PoolGet()
    effect._Handle = handle
    effect._Unit = nil
    effect._Center = Types.Point.Create(x, y)
    return effect
end

function mt.UnitEffect(modelName, unit, slot)
    local handle = jass.AddSpecialEffectTarget(modelName, unit._Handle, slot)
    local effect = PoolGet()
    effect._Handle = handle
    effect._Unit = unit
    return effect
end

return mt
