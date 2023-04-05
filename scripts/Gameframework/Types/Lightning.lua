local jass = require 'jass.common'
local dbg = require 'jass.debug'


local mt = {}
mt.__index = mt
mt.Type = "Lightning"
mt._Color = nil
mt._Handle = 0
mt._PointA = nil
mt._PointB = nil
mt._PointA_ZOffest = 0
mt._PointB_ZOffest = 0


function mt:SetPoisition(startPoint, endPoint)
    if self._Color.alpha == 0 then return end

    self._PointA:CopyFrom(startPoint)
    self._PointB:CopyFrom(endPoint)
    local x1, y1, z1 = startPoint:Unpack()
    local x2, y2, z2 = endPoint:Unpack()

    jass.MoveLightningEx(self._Handle, false, x1, y1, z1 + self._PointA_ZOffest,
        x2, y2, z2 + self._PointB_ZOffest)
end

function mt:SetColor(red, green, blue, alpha)
    self._Color.red = math.min(red / 100, 1)
    self._Color.green = math.min(green / 100, 1)
    self._Color.blue = math.min(blue / 100, 1)
    self._Color.alpha = math.min(alpha / 100, 1)
    jass.SetLightningColor(self._Handle, self._Color.red, self._Color.green,
        self._Color.blue, self._Color.alpha)
end

function mt:Hide()
    jass.SetLightningColor(self._Handle, self._Color.red, self._Color.green,
        self._Color.blue, 0)
end

function mt:Show()
    jass.SetLightningColor(self._Handle, self._Color.red, self._Color.green,
        self._Color.blue, self._Color.alpha)
end

function mt:Clear()
    jass.DestroyLightning(self._Handle)
    self._Handle = 0
    Yuyuko.RefrencePool.Push(self._PointA)
    Yuyuko.RefrencePool.Push(self._PointB)
    self._PointA_ZOffest = 0
    self._PointB_ZOffest = 0
end

local Collection = {}
local function PoolGet()
    local count = #Collection
    if count > 0 then
        return table.remove(Collection)
    else
        local t = setmetatable({}, mt)
        t._Color = { red = 100, green = 100, blue = 100, alpha = 100 }
        t._PointA = Types.Point.Create(0, 0, 0)
        t._PointB = Types.Point.Create(0, 0, 0)
        return t
    end
end
Yuyuko.RefrencePool[mt.Type] = Collection


function mt.Create(name, startPoint, endPoint, startZOffset, endZOffest)
    local lightning = PoolGet()
    lightning._Handle = jass.AddLightning(name, true, 0, 0, 0, 0)
    lightning._PointA_ZOffest = startZOffset
    lightning._PointB_ZOffest = endZOffest
    lightning:SetPoisition(startPoint, endPoint)
    return lightning
end
