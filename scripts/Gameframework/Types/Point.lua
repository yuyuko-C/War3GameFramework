local jass = require 'jass.common'


local mt = {}
mt.__index = mt
mt.Type = "Point"
mt._X = 0
mt._Y = 0
mt._Z = 0


local dummy = jass.Location(0, 0)


-- 作为向量计算:夹角
function mt.Angle(p1, p2)
    if (p1.Type == "Point") and (p2.Type == "Point") then
        local cos = mt.Dot(p1, p2) / (p1:Magtitude() * p2:Magtitude())
        return math.deg(math.acos(cos))
    end
end

-- 作为向量计算：点乘
function mt.Dot(p1, p2)
    if (p1.Type == "Point") and (p2.Type == "Point") then
        local x1, y1, z1 = p1:Unpack()
        local x2, y2, z2 = p2:Unpack()
        return x1 * x2 + y1 * y2 + z1 * z2
    end
end

-- 作为向量计算：叉乘
function mt.Cross(p1, p2)
    if (p1.Type == "Point") and (p2.Type == "Point") then
        local x1, y1, z1 = p1:Unpack()
        local x2, y2, z2 = p2:Unpack()
        local x, y, z = y2 * z1 - z2 * y1, z2 * x1 - x2 * z1, x2 * y1 - y2 * x1
        return mt.Create(x, y, z)
    end
end

-- 作为点计算：距离
function mt.Distance(p1, p2)
    if (p1.Type == "Point") and (p2.Type == "Point") then
        local point = mt.Create(p1._X - p2._X, p1._Y - p2._Y,
            p1._Z - p2._Z)
        local distance = point:Magtitude()
        Yuyuko.RefrencePool.Push(point)
        return distance
    end
end

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

function mt:__tostring()
    return ('Point:{%.4f, %.4f, %.4f}'):format(self._X, self._Y, self._Z)
end

-- 作为向量计算:长度 副本
function mt:Magtitude()
    return math.sqrt(self._X ^ 2 + self._Y ^ 2 + self._Z ^ 2)
end

-- 作为向量计算:归一化
function mt:Nomorlized()
    local magtitude = self:Magtitude()
    return mt.Create(self._X / magtitude, self._Y / magtitude,
        self._Z / magtitude)
end

-- 获取点的三维坐标
-- flag:布尔值,是否获取z轴坐标
function mt:Unpack(flag)
    return self._X, self._Y, flag and self:GetZ() or self._Z
end

-- 计算地面的z轴坐标
function mt:GetZ()
    -- 移动jass点到点自身的x,y ,再计算jass点的所处高度
    jass.MoveLocation(dummy, self._X, self._Y)
    return jass.GetLocationZ(dummy)
end

-- 复制目标点的三维坐标
function mt:CopyFrom(dest)
    self._X, self._Y, self._Z = dest._X, dest._Y, dest._Z
end

-- 获得地层高度
-- 深水区0，浅水区1，平原2，之后每层+1
function mt:GetLevel() return jass.GetTerrainCliffLevel(self:Unpack()) end

-- 检查点是否在范围内
function mt:IsInArea(area)
    if (area.Type == "Circle") then
        return area:Center() * self < area._Radius
    elseif (area.Type == "Rect") then
        local x, y = self:Unpack()
        local minx, miny, maxx, maxy = area:Unpack()
        if (x > maxx) or (x < minx) or (y > maxy) or (y < miny) then
            return false
        else
            return true
        end
    elseif (area.Type == "Region") then
        return jass.IsPointInRegion(area._Handle, self._X, self._Y)
    end
end

-- 点是否对玩家可见
function mt:IsVisiableToPlayer(player)
    if player.Type == "Player" then
        return jass.IsVisibleToPlayer(self._X, self._Y, player._Handle)
    else
        error('错误的类型' .. tostring(player.Type))
    end
end

-- 是否无法通行
-- 是否无视地面阻挡(飞行)
-- 是否无视地图边界
function mt:IsBlock(path, super)
    local x, y = self:Unpack()
    if not path then if jass.IsTerrainPathable(x, y, 1) then return true end end
    if not super then if jass.IsTerrainPathable(x, y, 2) then return true end end
    return false
end

-- 在附近寻找一个可通行的点
--	[采样范围]
--	[初始角度]
--	[不包含当前位置]
function mt:FindMoveablePoint(r, angle, other)
    local r = r or 512
    local angle = angle or 0
    if not other and not self:IsBlock() then return self end

    for r = math.min(r, 32), r, 32 do
        for angle = angle, angle + 315, 45 do
            local p = self - { angle, r }
            if not p:IsBlock() then return p end
        end
    end
end

---求是否穿过不可通行区域
---@param point table 目标点
---@return table point 最后一个可通行的点
function mt:GetLastWalkablePoint(point)
    if point.Type == "Point" then
        local angle = math.deg(self / point)
        local distance = self * point
        local re = mt.Create(self:Unpack())
        local next
        while distance >= 0 do
            distance = distance - 32
            next = re - { angle, 32 }
            re:CopyFrom(next)
            Yuyuko.RefrencePool.Push(next)
            if next:IsBlock() then return re end
        end
        return re
    else
        error('错误的类型' .. tostring(point.Type))
    end
end

-- 按照直角坐标系移动(point + {x, y})
--	@新点
function mt:__add(data)
    if data.Type == "Point" then
        return mt.Create(self._X + data._X, self._Y + data._Y,
            self._Z + (data._Z or 0))
    else
        error('错误的类型' .. tostring(data.Type))
    end
end

-- 按照极坐标系移动(point - {angle, distance})
--	@新点
function mt:__sub(data)
    local x, y, z = self:Unpack()
    local angle, distance = data[1], data[2]
    return mt.Create(x + distance * math.cos(angle),
        y + distance * math.sin(angle), z)
end

-- 求距离(point * point)
function mt:__mul(data)
    if data.Type == "Point" then
        local x1, y1 = self:Unpack()
        local x2, y2 = data:Unpack()
        local x0, y0 = x1 - x2, y1 - y2
        return math.sqrt(x0 * x0 + y0 * y0)
    else
        error('错误的类型' .. tostring(data.Type))
    end
end

-- 求方向(point / point)
-- 返回值为弧度制，方向为self指向data
function mt:__div(data)
    if data.Type == "Point" then
        local x1, y1 = self:Unpack()
        local x2, y2 = data:Unpack()
        return math.atan(y2 - y1, x2 - x1)
    else
        error('错误的类型' .. tostring(data.Type))
    end
end

-- 求相等(point == point)
function mt:__eq(data)
    if data.Type == "Point" then
        return (self._X == data._X) & (self._Y == data._Y) &
            (self._Z == data._Z)
    else
        error('错误的类型' .. tostring(data.Type))
    end
end

function mt:Clear()
    self._X = 0
    self._Y = 0
    self._Z = 0
end

-- 获得命令目标点
function mt.GetOrderPoint()
    return mt.Create(jass.GetOrderPointX(), jass.GetOrderPointY())
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

function mt.Create(x, y, z)
    local point = PoolGet()
    point._X = x or 0
    point._Y = y or 0
    point._Z = z or 0
    return point
end

function mt.init()
    -- 命令发布点
    local j_trg = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitOrderPointEventArgs.EventID, nil)
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(j_trg, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, nil)
    end
end

return mt
