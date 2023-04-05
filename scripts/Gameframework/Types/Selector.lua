local jass = require 'jass.common'

local dummy = jass.CreateGroup()
local MAX_COLLISION = 200


local mt = {}
mt.__index = mt
mt.Type = "Selector"
mt._Center = nil
mt._Radius = 9999
mt._FilterMode = nil
mt._FilterActions = nil
mt._SelectUnits = nil

-- #region 局部函数

-- 执行筛选,对选取到的单位进行过滤
local function DoFilter(self, _unit)
    local actions = self._FilterActions
    for i = 1, #actions do
        local filter = actions[i]
        if not filter(_unit) then return false end
    end
    return true
end

-- 单位是否位于圆形范围内
local function UnitIsInRange(_unit, center, radius)
    return _unit:Center() * center - _unit._SelectedRadius <= radius
end

-- 单位是否位于矩形范围内
local function UnitIsInRect(_unit, rect_start, vectorFace, rect_width)
    -- 从起点指向被选中单位的向量
    local enumX, enumY = _unit:Center():Unpack()
    local vectorToEnum =
        Types.Point.Create(enumX - rect_start.x, enumY - rect_start.y)

    -- 两向量的夹角
    local degAngle = math.rad(Types.Point.Angle(vectorToEnum, vectorFace))
    -- 矩形起点到选中单位的距离
    local enumLength = vectorToEnum:Magtitude()

    local length = math.cos(degAngle) * enumLength - _unit._SelectedRadius
    local width = math.sin(degAngle) * enumLength - _unit._SelectedRadius

    return (length < vectorFace:Magtitude()) and (width < rect_width / 2)
end

-- 添加单位进war3单位组
local function DoSelect(self)
    if self._FilterMode == 0 then
        --	圆形选取
        local x, y = self._Center:Unpack()
        local r = self._Radius

        jass.GroupEnumUnitsInRange(dummy, x, y, r + MAX_COLLISION, nil)

        jass.ForGroup(dummy, function()
            local enumUnit = Types.Unit.GetByHandle(jass.GetEnumUnit())
            if enumUnit then
                if UnitIsInRange(enumUnit, self._Center, r) and
                    DoFilter(self, enumUnit) then
                    table.insert(self._SelectUnits, enumUnit)
                end
            end
        end)

        jass.GroupClear(dummy)
    elseif self._FilterMode == 1 then
        --	扇形选取
        local x, y = self._Center:get()
        local r = self._Radius
        local angle = self._Angle
        local section = self._Selection / 2

        jass.GroupEnumUnitsInRange(dummy, x, y, r + MAX_COLLISION, nil)

        jass.ForGroup(dummy, function()
            local enumUnit = Types.Unit.GetByHandle(jass.GetEnumUnit())
            if enumUnit and UnitIsInRange(enumUnit, self._Center, r) then
                if math.math_angle(angle, self._Center / enumUnit:Center()) <=
                    section and DoFilter(self, enumUnit) then
                    table.insert(self._SelectUnits, enumUnit)
                end
            end
        end)

        jass.GroupClear(dummy)
    elseif self._FilterMode == 2 then
        --	矩形选取
        local start = self._Center
        local target = start - { self._Angle, self._Len }

        local radius = self._Len / 2

        -- 矩形中心
        local rect_center = Types.Point:Create((start.x + target.x) / 2,
            (start.y + target.y) / 2)

        -- 从起点指向终点的向量
        local vectorFace = Types.Point:Create(target.x - start.x, target.y - start.y)

        jass.GroupEnumUnitsInRange(dummy, rect_center.x, rect_center.y,
            radius + MAX_COLLISION, nil)

        jass.ForGroup(dummy, function()
            local enumUnit = Types.Unit.GetByHandle(jass.GetEnumUnit())
            if enumUnit and UnitIsInRange(enumUnit, rect_center, radius) then
                -- 排除在矩形之外的向量
                if UnitIsInRect(enumUnit, start, vectorFace, self._Width) and
                    DoFilter(self, enumUnit) then
                    table.insert(self._SelectUnits, enumUnit)
                end
            end
        end)

        jass.GroupClear(dummy)
    end
end

-- #endregion

-- #region 外部执行函数


-- 获取符合条件的Lua单位组，若不存在符合条件的单位则返回空Table
function mt:GetSelectUnits()
    DoSelect(self)
    local len = #self._SelectUnits
    if len > 0 then
        if self._Sorter then table.sort(self._SelectUnits, self._Sorter) end
    end
    return self._SelectUnits
end

-- 加入筛选条件
function mt:AddFilter(func)
    table.insert(self._FilterActions, func)
    return self
end

-- 选取并选出随机单位
function mt:GetRandomUnit()
    local g = self:GetSelectUnits()
    if #g > 0 then return g[math.random(1, #g)] end
end

-- 圆形范围
--	圆心
--	半径
function mt:InRange(center, radius)
    self._FilterMode = 0
    self._Center = center
    self._Radius = radius
    return self
end

-- 扇形范围
--	圆心
--	半径
--	角度
--	区间
function mt:InSector(center, radius, angle, section)
    self._FilterMode = 1
    self._Center = center
    self._Radius = radius
    self._Angle = angle
    self._Selection = section
    return self
end

-- 直线范围
--	起点
--	角度
--	长度
--	宽度
function mt:InLine(center, angle, len, width)
    self._FilterMode = 2
    self._Center = center
    self._Angle = angle
    self._Len = len
    self._Width = width
    return self
end

-- 设置选取单位的排序方式
function mt:SetSorter(func)
    self._Sorter = func
    return self
end

-- 排序权重：1、英雄 2、和point的距离
function mt:SortByHeroOrDistance(point)
    return self:SetSorter(function(u1, u2)
        if u1:IsType('英雄') and not u2:IsType('英雄') then
            return true
        end
        if not u1:IsType('英雄') and u2:IsType('英雄') then
            return false
        end
        return u1:Center() * point < u2:Center() * point
    end)
end

-- #endregion

-- #region 条件筛选

-- 不是指定单位
--	单位
function mt:IsNotUnit(u)
    return self.AddFilter(self, function(dest) return dest ~= u end)
end

-- 是敌人
-- 单位/玩家
function mt:IsEnemyTo(obj)
    return self.AddFilter(self, function(dest)
        if obj.Type == "Unit" then
            return dest._Player:IsEnemy(obj._Player)
        elseif obj.Type == "Player" then
            return dest._Player:IsEnemy(obj)
        end
    end)
end

-- 是友军
-- 单位/玩家
function mt:IsAllyTo(obj)
    return self.AddFilter(self, function(dest)
        if obj.Type == "Unit" then
            return dest._Player:IsAlly(obj._Player)
        elseif obj.Type == "Player" then
            return dest._Player:IsAlly(obj)
        end
    end)
end

-- 是此类型
-- 自定义类型(字符串)
function mt:IsType(type)
    return self.AddFilter(self,
        function(dest) return dest:IsType(type) end)
end

-- 不是此类型
-- 自定义类型(字符串)
function mt:IsNotType(type)
    return self.AddFilter(self,
        function(dest) return not dest:IsType(type) end)
end

-- 是可见的
function mt:IsVisiableTo(player)
    return self.AddFilter(self, function(dest)
        return player:IsUnitVisiable(dest)
    end)
end

-- 是War3无敌的
function mt:IsUnitInvulnerable()
    return self.AddFilter(self, function(dest) return dest:IsUnitInvulnerable() end)
end

-- 不用是War3无敌的
function mt:IsNotUnitInvulnerable()
    return self.AddFilter(self,
        function(dest) return not dest:IsUnitInvulnerable() end)
end

-- 必须是存活的
function mt:IsAlive()
    return self.AddFilter(self, function(dest) return not dest:IsAlive() end)
end

-- 必须是死亡的
function mt:IsNotAlive()
    return self.AddFilter(self, function(dest) return not dest:IsAlive() end)
end

-- #endregion

function mt:Clear()
    self._Center = nil
    self._Radius = 9999
    self._FilterMode = nil
    Yuyuko.LinqList.Clear(self._FilterActions)
    Yuyuko.LinqList.Clear(self._SelectUnits)
end

local Collection = {}
local function PoolGet()
    local count = #Collection
    if count > 0 then
        return table.remove(Collection)
    else
        local t = setmetatable({}, mt)
        t._FilterActions = {}
        t._SelectUnits = {}
        return t
    end
end
Yuyuko.RefrencePool[mt.Type] = Collection


function mt.Create()
    local selector = PoolGet()
    return selector
end

return mt
