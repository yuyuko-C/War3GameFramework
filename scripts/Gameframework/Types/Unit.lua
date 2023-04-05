local jass = require "jass.common"
local japi = require "jass.japi"
local dbg = require "jass.debug"
local slk = require "jass.slk"

local Rect = require "Gameframework.Types.Rect"
local UnitProperty = require "Gameframework.Types.UnitProperty"



local mt = {}
mt.__index = mt
mt.Type = "Unit"
mt._ID = 0
mt._Handle = nil
mt._Name = nil
mt._Player = nil
mt._Center = Types.Point
mt._Level = nil
-- 颜色
mt._Color = nil
-- 大小
mt._Size = 1
mt._DefaultSize = nil
-- 高度
mt._Height = 0
-- 动画
mt._AnimationProperties = ''
-- 选择半径
mt._SelectedRadius = nil
-- 最霸道的开关状态
mt._Switches = nil
-- 是否War3无敌
mt._IsInvulnerable = false
-- 自定义单位类型
mt._CustomType = ""
-- 单位属性
mt._Properties = { UnitProperty }


local allInstance = { mt }
table.remove(allInstance)

local removedHandles = setmetatable({}, { __mode = "kv" })


-- 普攻伤害捕捉触发器, 捕捉普攻事件(每个单位都需要注册)
local normalAtkTrig = Yuyuko.CreateTrigger(function()
    Yuyuko.EventManager.Fire(Events.War3UnitGetDamageEventArgs.EventID, nil)
end)

function mt:__tostring()
    return ('Unit:{name:%s, handle:%s}'):format(self._Name, self._Handle)
end

function mt:IsType(str)
    return self._CustomType == str
end

-- 获得所有者
function mt:GetOwner() return self._Player end

-- 设置所有者
function mt:SetOwner(player, color)
    self._Player = player
    jass.SetUnitOwner(self._Handle, player._Handle, not (not color))
end

-- 是否存活
function mt:IsAlive()
    return not jass.IsUnitType(self._Handle, jass.UNIT_TYPE_DEAD)
end

-- 杀死
function mt:Kill()
    if not self:IsAlive() then return end
    jass.KillUnit(self._Handle)
end

-- 复活英雄
-- @坐标 X
-- @坐标 Y
-- @是否隐藏复活动画
function mt:ReviveHero(x, y, hideAnim)
    jass.ReviveHero(self._Handle, x, y, hideAnim)
end

-- 设置等级
--	等级
function mt:SetLevel(level)
    if level > self:GetLevel() then
        jass.SetHeroLevel(self._Handle, level,
            jass.IsUnitType(self._Handle, jass.UNIT_TYPE_HERO))
    end
end

-- 获取等级
function mt:GetLevel() return self._Level end

function mt:SetUnitInvulnerable(flag)
    jass.SetUnitInvulnerable(self._Handle, flag)
end

-- 设置War3无敌的
function mt:SetUnitInvulnerable(flag)
    self._IsInvulnerable = flag
    jass.SetUnitInvulnerable(self._Handle, flag)
end

-- 是否War3无敌的
function mt:IsUnitInvulnerable()
    return self._IsInvulnerable
end

function mt:InitProperty(name, fixed, variable)
    local property = self._Properties[name]
    if property ~= nil then
        error("已初始化过的属性:" .. name)
        return
    end
    property = UnitProperty.Create(self, name, fixed)
    property:SetVariable(variable)
    self._Properties[name] = property
end

---获取属性
function mt:GetProperty(name)
    if self._Properties[name] == nil then
        error("未初始化过的属性:" .. name)
    end

    return self._Properties[name]
end

-- #region 单位显示

-- 单位位置
function mt:Center()
    local x, y = jass.GetUnitX(self._Handle), jass.GetUnitY(self._Handle)
    self._Center._X = x
    self._Center._Y = y
    return self._Center
end

---设置单位位置
---@param x number
---@param y number
function mt:SetCenter(x, y)
    local point = Types.Point.Create(x, y)
    if not point:IsInArea(Rect.Map) then
        Yuyuko.Log.error(mt.Type .. '目标点超出地图范围')
        self._Player:SendMsg('目标点超出地图范围', 5)
    else
        jass.SetUnitX(self._Handle, x)
        jass.SetUnitY(self._Handle, y)
    end

    Yuyuko.RefrencePool.Push(point)
    -- 下面的移动方式只适用于移动速度不为0的单位
    -- 当单位移速为0时只会改变碰撞器位置，不会改变模型位置
    -- jass.SetUnitX(self._Handle, x)
    -- jass.SetUnitY(self._Handle, y)

    -- 下面的移动方式能在移速为0时使用，但因为其机制相当于刷新单位，小地图会显示异常
    -- jass.SetUnitPosition(self._Handle, x, y)
end

-- 设置转身速度
function mt:SetTurnSpeed(speed)
    jass.SetUnitTurnSpeed(self._Handle, speed);
end

-- 获取转身速度
function mt:GetTurnSpeed()
    return jass.GetUnitTurnSpeed(self._Handle)
end

-- 设置大小
--	大小
function mt:SetSize(size)
    self._Size = size
    size = size * self._DefaultSize
    jass.SetUnitScale(self._Handle, size, size, size)
end

-- 获取大小
function mt:GetSize() return self._Size end

-- 增加大小
--	大小
function mt:AddSize(size)
    size = size + self:GetSize()
    self:SetSize(size)
end

-- 获取高度
--	[是否是绝对高度(地面高度+飞行高度)]
function mt:GetHeight(b)
    if b then
        return self:Center():GetZ() + self._Height
    else
        return self._Height
    end
end

-- 设置高度
--	高度
--	[是否是绝对高度]
function mt:SetHeight(height, b, change_time)
    if b then
        self._Height = height - self:Center():GetZ()
    else
        self._Height = height
    end
    jass.SetUnitFlyHeight(self._Handle, self._Height, change_time or 0)
end

-- 增加高度
--	高度
--	[是否是绝对高度]
function mt:AddHeight(height, b)
    self:SetHeight(self:GetHeight(b) + height)
end

-- 隐藏单位(这个会让Selector也无法找到)
function mt:Hide(flag) jass.ShowUnit(self._Handle, not flag) end

-- 朝向
-- 获得朝向
function mt:GetFacing() return jass.GetUnitFacing(self._Handle) end

-- 设置朝向
--	朝向
--  瞬间转身
function mt:SetFacing(angle, instant)
    if instant then
        japi.EXSetUnitFacing(self._Handle, angle)
    else
        jass.SetUnitFacing(self._Handle, angle)
    end
end

-- 设置单位颜色
--	[红(%)]
--	[绿(%)]
--	[蓝(%)]
function mt:SetColor(red, green, blue)
    self._Color.red, self._Color.green, self._Color.blue = red, green, blue
    jass.SetUnitVertexColor(self._Handle, self._Color.red * 2.55,
        self._Color.green * 2.55, self._Color.blue * 2.55,
        self._Color.alpha * 2.55)
end

-- 设置单位透明度
--	透明度(%)
function mt:SetAlpha(alpha)
    self._Color.alpha = alpha
    jass.SetUnitVertexColor(self._Handle, self._Color.red * 2.55,
        self._Color.green * 2.55, self._Color.blue * 2.55,
        self._Color.alpha * 2.55)
end

-- 获取单位透明度(%)
function mt:GetAlpha() return self._Color.alpha end

-- 动画
-- 设置单位动画
--	动画名或动画序号
function mt:SetUnitAnimation(ani)
    if not self:IsAlive() then return end
    if type(ani) == 'string' then
        jass.SetUnitAnimation(self._Handle, self._AnimationProperties .. ani)
    else
        jass.SetUnitAnimationByIndex(self._Handle, ani)
    end
end

-- 将动画添加到队列
--	动画序号
function mt:AddAnimationToQueue(ani)
    if not self:IsAlive() then return end
    jass.QueueUnitAnimation(self._Handle, ani)
end

-- 设置动画播放速度
--	速度
function mt:SetAnimationSpeed(speed)
    jass.SetUnitTimeScale(self._Handle, speed)
end

-- 添加动画附加名
--	附加名
function mt:AddAnimationProperties(name)
    jass.AddUnitAnimationProperties(self._Handle, name, true)
    self._AnimationProperties = self._AnimationProperties .. name .. ' '
end

-- 移除动画附加名
--	附加名
function mt:RemoveAnimationProperties(name)
    jass.AddUnitAnimationProperties(self._Handle, name, false)
    self._AnimationProperties = self._AnimationProperties:gsub(name .. ' ', '')
end

-- #endregion

--#region 命令

function mt:IssueOrder(order)
    jass.IssueImmediateOrder(self._Handle, order)
end

function mt:IssuePointOrder(order, x, y)
    jass.IssuePointOrder(self._Handle, order, x, y)
end

function mt:IssueTargetOrder(order, typeObj)
    jass.IssueTargetOrder(self._Handle, order, typeObj._Handle)
end

--#endregion

-- #region 物品

function mt:AddItem(item)
    return jass.UnitAddItem(self._Handle, item)
end

function mt:DropItem(item)
    jass.UnitRemoveItem(self._Handle, item)
end

-- #endregion

-- #region 魔兽自带技能

function mt:AddAbility(abilityID)
    jass.UnitAddAbility(self._Handle, abilityID)
    jass.UnitMakeAbilityPermanent(self._Handle, true, abilityID)
end

function mt:RemoveAbility(abilityID)
    jass.UnitMakeAbilityPermanent(self._Handle, false, abilityID)
    jass.UnitRemoveAbility(self._Handle, abilityID)
end

function mt:SetAbilityLevel(abilityID, level)
    jass.SetUnitAbilityLevel(self._Handle, abilityID, level)
end

-- #endregion


-- 获取物编数据
--	数据项名称
--	[如果未找到,返回的默认值]
function mt:GetSlk(name, default)
    local unit_data = slk.unit[self._ID]
    if not unit_data then
        Yuyuko.Log.error('单位数据未找到', self._ID)
        return default
    end
    local data = unit_data[name]
    if data == nil then return default end
    if type(default) == 'number' then return tonumber(data) or default end
    return data
end

function mt:Clear()
    self._ID = 0
    self._Name = nil
    self._Player = nil
    Yuyuko.RefrencePool.Push(self._Center)
    self._Center = nil
    jass.RemoveUnit(self._Handle)
    dbg.handle_unref(self._Handle)
    self:ClearItem()
    self:ClearAbility()
    allInstance[self._Handle] = nil
    removedHandles[self._Handle] = true
    self._Handle = nil
end

-- #region 类函数

function mt.GetByHandle(handle)
    return allInstance[handle]
end

-- 技能释放目标单位
function mt.GetSpellTargetUnit()
    return mt.GetByHandle(jass.GetSpellTargetUnit())
end

-- 获取目标命令的目标单位
function mt.GetOrderTargetUnit()
    return mt.GetByHandle(jass.GetOrderTargetUnit())
end

-- 触发单位
function mt.GetTriggerUnit()
    return mt.GetByHandle(jass.GetTriggerUnit())
end

-- 伤害来源单位
function mt.GetEventDamageSource()
    return mt.GetByHandle(jass.GetEventDamageSource())
end

local Collection = {}
local function PoolGet()
    local count = #Collection
    if count > 0 then
        return table.remove(Collection)
    else
        local t = setmetatable({}, mt)
        return t
    end
end
Yuyuko.RefrencePool[mt.Type] = Collection


function mt.Create(player, unitID, x, y, face)
    local handle = jass.CreateUnit(player._Handle, unitID, x, y, face)
    local unit = mt.CreateByHandle(handle)
    allInstance[handle] = unit
    return unit
end

-- 以handle构建一个单位(可以获得对地图上摆放的单位的控制)
function mt.CreateByHandle(handle)
    if (not handle) or (handle == 0) then return nil end
    if removedHandles[handle] then return nil end
    if allInstance[handle] then return allInstance[handle] end
    local unit = PoolGet()
    unit._Handle = handle
    dbg.handle_ref(unit._Handle)
    unit._ID = jass.GetUnitTypeId(handle)
    unit._Name = unit:GetSlk("Propernames") or unit:GetSlk("Name")
    unit._Player = Types.Player.GetByHandle(jass.GetOwningPlayer(handle))
    unit._Center = Types.Point.Create(jass.GetUnitX(unit._Handle),
        jass.GetUnitY(unit._Handle))
    unit._Level = jass.GetHeroLevel(unit._Handle)
    unit._Color = { red = 100, green = 100, blue = 100, alpha = 100 }
    unit._DefaultSize = tonumber(unit:GetSlk 'modelScale') or 1
    unit._AnimationProperties = ''
    unit._SelectedRadius = unit:GetSlk("collision", 32)
    unit._Properties = { UnitProperty }
    table.remove(unit._Properties)

    -- 令物体可以飞行
    local int_id = Yuyuko.String2ID('Arav')
    jass.UnitAddAbility(unit._Handle, int_id)
    jass.UnitRemoveAbility(unit._Handle, int_id)

    -- 忽略警戒点
    jass.RemoveGuardPosition(unit._Handle)
    jass.SetUnitCreepGuard(unit._Handle, true)

    -- 设置高度
    unit:SetHeight(unit:GetSlk('moveHeight', 0))

    -- 注册受到伤害事件
    jass.TriggerRegisterUnitEvent(normalAtkTrig, handle, jass.EVENT_UNIT_DAMAGED)

    -- 蝗虫技能等级
    local lv = jass.GetUnitAbilityLevel(unit._Handle, Yuyuko.String2ID('Aloc'))

    -- 将其作为弹幕
    if lv ~= 0 then unit._CustomType = "弹幕" end

    return unit
end

-- 此单位需要碰撞体积是0 , 单位类型为守卫,  在小地图隐藏
local missileID = Yuyuko.String2ID("hpea")

-- 创建一个完全用于模型和动画展示的单位
-- 单位数据除了模型其他的都一致
function mt.CreateModel(model, x, y, face)
    japi.EXSetUnitString(missileID, 13, model)
    local unit = Types.Unit.Create(Types.Player[16], missileID, x, y, face)
    if unit then
        -- 必须要添加蝗虫, 使其不可被玩家选定就不会露馅
        unit:AddAbility(Yuyuko.String2ID("Aloc"))
    end
end

-- #endregion


return mt
