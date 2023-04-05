local jass = require 'jass.common'


-- 仅仅是正矩形，不能表示会倾斜的矩形
local mt = {}
mt.__index = mt
mt.Type = "Rect"
mt._Minx = 0
mt._Miny = 0
mt._Maxx = 0
-- 初始化以确定类型,从而使用代码补全
mt._Center = Types.Point
mt._Name = nil

local dummy = jass.Rect(0, 0, 0, 0)


function mt:__tostring()
    return ('Rect:{%.4f, %.4f, %.4f, %.4f}'):format(self:Unpack())
end

-- 获取4个值
function mt:Unpack()
    return self._Minx, self._Miny, self._Maxx, self._Maxy
end

-- 获取中心点
function mt:Center() return self._Center end

-- 扩展矩形区域
-- @新矩形
function mt:__add(data)
    if data.Type == 'Rect' then
        local minx0, miny0, maxx0, maxy0 = self:Unpack()
        local minx1, miny1, maxx1, maxy1 = data:Unpack()

        local minx = math.min(minx0, minx1)
        local miny = math.min(miny0, miny1)
        local maxx = math.max(maxx0, maxx1)
        local maxy = math.max(maxy0, maxy1)
        return mt.Create(self._Name, minx, miny, maxx, maxy)
    else
        error('错误的类型' .. tostring(data.Type))
    end
end

function mt:Clear()
    mt[self._Name] = nil
    self._Minx = 0
    self._Miny = 0
    self._Maxx = 0
    self._Maxy = 0
    Yuyuko.RefrencePool.Push(self._Center)
    self._Center = nil
    self._Name = nil
end

function mt.GetRectByName(name)
    if not mt[name] then
        local jRect = jass['gg_rct_' .. name]
        mt[name] = mt.Create(name, jass.GetRectMinX(jRect),
            jass.GetRectMinY(jRect),
            jass.GetRectMaxX(jRect),
            jass.GetRectMaxY(jRect))
    end
    return mt[name]
end

-- 将当前区域转换为jass区域.
-- 返回值将会在下次调用ToJRect时发生变化,需马上使用.
function mt.ToJRect(rect)
    jass.SetRect(dummy, rect:Unpack())
    return dummy
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


function mt.Create(name, minx, miny, maxx, maxy)
    local rect = PoolGet()
    rect._Name = name
    rect._Minx = minx
    rect._Miny = miny
    rect._Maxx = maxx
    rect._Maxy = maxy
    rect._Center = Types.Point.Create((miny + maxx) / 2, (miny + maxy) / 2)
    mt[name] = rect
    return rect
end

-- 初始化
function mt.init()
    local minx = jass.GetCameraBoundMinX() -
        jass.GetCameraMargin(jass.CAMERA_MARGIN_LEFT) + 32
    local miny = jass.GetCameraBoundMinY() -
        jass.GetCameraMargin(jass.CAMERA_MARGIN_BOTTOM) + 32
    local maxx = jass.GetCameraBoundMaxX() +
        jass.GetCameraMargin(jass.CAMERA_MARGIN_RIGHT) - 32
    local maxy = jass.GetCameraBoundMaxY() +
        jass.GetCameraMargin(jass.CAMERA_MARGIN_TOP) - 32

    mt.Map = mt.Create("Map", minx, miny, maxx, maxy)
end

return mt
