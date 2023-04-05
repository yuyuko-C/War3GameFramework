local Point = require "Gameframework.Types.Point"

local mt = {}
mt.__index = mt
mt.Type = "Circle"
-- 初始化以确定类型,从而使用代码补全
mt._Center = Point
mt._Radius = 0


function mt:__tostring()
    return ('Circle:{center:(%.4f, %.4f), radius:%.4f}'):format(self:Unpack())
end

function mt:Unpack()
    return self._Center.X, self._Center.Y, self._Radius
end

function mt:Center() return self._Center end


function mt:Clear()
    self._Center = nil
    self._Radius = 0
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


function mt.Create(point, radius)
    local circle = PoolGet()
    circle._Center = point
    circle._Radius = radius
    return circle
end


return mt
