local jass = require 'jass.common'
local japi = require "jass.japi"
local slk = require "jass.slk"


local mt = {}
mt.__index = mt
mt.Type = "Ability"
mt._Handle = 0
mt._ID = 0
mt._Name = nil
mt._Order = nil
mt._Hotkey = nil
mt._Level = 0
mt._MaxLevel = 0
mt._Cool = 0
mt._MaxCool = 0
mt._Unit = Types.Unit

local allInstance = { mt }
table.remove(allInstance)

function mt:InitByUnitAndAbilityID(unit, abilityID)
    local handle = japi.EXGetUnitAbility(unit._Handle, abilityID)
    if (handle == 0) then
        jass.UnitAddAbility(unit._Handle, abilityID)
        jass.UnitMakeAbilityPermanent(unit._Handle, true, abilityID)
        handle = japi.EXGetUnitAbility(unit._Handle, abilityID)
    end

    self._Handle = handle
    self._ID = abilityID
    self._Name = self:GetSlk('Name', '')
    self._Order = self:GetSlk('DataF', '')
    self._Hotkey = self:GetSlk('Hotkey', '')
    self._Level = jass.GetUnitAbilityLevel(unit._Handle, abilityID)
    self._MaxLevel = self:GetSlk('levels', '')
    self._Cool = japi.EXGetAbilityState(self._Handle, 0x01)
    self._MaxCool = self:GetSlk('Cool', '')
    self._Unit = unit

    allInstance[self._Handle] = self
end

-- #region 逻辑区

-- 设置标题
function mt:SetTip(title, level)
    if japi.EXSetAbilityString then
        japi.EXSetAbilityString(self._ID, level, 0xD7, title)
    else
        japi.EXSetAbilityDataString(self._Handle, level, 0xD7, title)
    end
end

-- 设置描述
function mt:SetUbertip(ubertip, level)
    if japi.EXSetAbilityString then
        japi.EXSetAbilityString(self._ID, level, 0xDA, ubertip)
    else
        japi.EXSetAbilityDataString(self._Handle, level, 0xDA, ubertip)
    end
end

-- 设置图标
function mt:SetArtIcon(iconPath, level)
    japi.EXSetAbilityString(self._ID, level, 0xCC, iconPath)
end

-- 设置热键
function mt:SetHotkey(hotkey, level)
    japi.EXSetAbilityDataInteger(self._Handle, level, 0xC8, hotkey)
end

-- 设置释放距离
function mt:SetCastRadius(radius, level)
    japi.EXSetAbilityDataReal(self._Handle, level, 0x6B, radius)
end

-- 设置影响范围
function mt:SetEffectRadius(radius, level)
    japi.EXSetAbilityDataReal(self._Handle, level, 0x6A, radius)
    -- 设置目标选取方式
    local options = (radius and 0x02 or 0x00) + 0x01
    japi.EXSetAbilityDataReal(self._Handle, level, 0x6E, options)
end

-- 设置蓝耗
function mt:SetManaCost(mana, level)
    japi.EXSetAbilityDataInteger(self._Handle, level, 0x68, mana)
end

-- 获取剩余冷却时间
function mt:GetCoolRemain()
    return japi.EXGetAbilityState(self._Handle, 0x01)
end

-- 设置剩余冷却时间
function mt:SetCoolRemain(seconds)
    japi.EXSetAbilityState(self._Handle, 0x01, seconds)
end

---获取最大冷却时间(释放间隔)
function mt:GetMaxCool(level)
    japi.EXGetAbilityDataReal(self._Handle, level, 0x69)
end

---设置最大冷却时间(释放间隔)
function mt:SetMaxCool(seconds, level)
    japi.EXSetAbilityDataReal(self._Handle, level, 0x69, seconds)
end

-- 设置目标类型(类枚举)
function mt:SetTargetType(targetType, level)
    japi.EXSetAbilityDataReal(self._Handle, level, 0x6D, targetType)
end

---设置目标允许(target_data可以通过函数convertTargets转换)
---@param target_data integer
---@param level integer
function mt:SetTargetAllow(target_data, level)
    japi.EXSetAbilityDataInteger(self._Handle, level, 0x64, target_data)

    -- 改变技能等级刷新目标允许
    local currentLevel = self:GetLevel();
    local changeLevel = currentLevel == 1 and 2 or 1;
    jass.SetUnitAbilityLevel(self._attacher._handle, self._ID, changeLevel)
    jass.SetUnitAbilityLevel(self._attacher._handle, self._ID, currentLevel)
end

---设置技能选项(类枚举)
---@param options any
---@param level any
function mt:SetOption(options, level)
    japi.EXSetAbilityDataReal(self._Handle, level, 0x6E, options)
end

-- 获取技能等级
function mt:GetLevel()
    return jass.GetUnitAbilityLevel(self._Unit._Handle, self._ID)
end

-- 设置技能等级
function mt:SetLevel(level)
    jass.SetUnitAbilityLevel(self._Unit._Handle, self._ID, level)
end

-- 刷新目标等级, 用于刷新目标允许
function mt:FreshLevel()
    if 1 == self._MaxLevel then return end
    if self._Level == self._MaxLevel then
        self:SetLevel(self._Level - 1)
        self:SetLevel(self._Level)
    else
        self:SetLevel(self._Level + 1)
        self:SetLevel(self._Level)
    end
end

-- #endregion

-- 获取物编数据
--	数据项名称
--	[如果未找到,返回的默认值]
function mt:GetSlk(name, default)
    local ability_data = slk.ability[self._ID]
    if not ability_data then
        print('技能数据未找到', Yuyuko.ID2String(self._ID))
        return default
    end
    local data = ability_data[name]
    if data == nil then return default end
    if type(default) == 'number' then return tonumber(data) or default end
    return data
end

function mt:Clear()
    jass.UnitRemoveAbility(self._Unit, self._ID)
    self._Handle = 0
    self._ID = 0
    self._Name = nil
    self._Order = nil
    self._Hotkey = nil
    self._Level = 0
    self._MaxLevel = 0
    self._Cool = 0
    self._MaxCool = 0
    self._Unit = nil

    Yuyuko.EventManager.UnSubscribe(Events.War3UnitSpellEffectEventArgs, self._CastEventAction)
    self._CastEventAction = nil
end

function mt.GetByHandle(handle)
    return allInstance[handle]
end

-- 获取释放的技能ID
function mt.GetSpellAbilityID()
    return jass.GetSpellAbilityId()
end

-- 获取学习的技能ID
function mt.GetLearnedAbilityID()
    return jass.GetLearnedSkill()
end

-- 获取学习后的技能等级
function mt.GetLearnednAbilityLevel()
    return jass.GetLearnedSkillLevel()
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

function mt.Create(unit, abilityID)
    local ability = PoolGet()
    ability:InitByUnitAndAbilityID(unit, abilityID)
    return ability
end

-- 转换目标允许为整数(游戏逻辑使用)
function mt.convertTargets(data)
    local result = 0
    for name in data:gmatch '%S+' do
        local flag = mt.convert_targets[name]
        if not flag then error('错误的目标允许类型: ' .. name) end
        result = result + flag
    end
    return result
end

function mt.init()
    -- 技能目标类型常量
    mt.TargetType = {
        NONE = 0,         -- 无目标
        UNIT = 1,         -- 单位目标
        POINT = 2,        -- 点目标
        UNIT_OR_POINT = 3 -- 单位或点
    }

    -- 常用的技能目标类型
    mt.TARGET_DATA_ENEMY = '敌人'
    mt.TARGET_DATA_ALLY = '自己 玩家单位 联盟'

    -- 转换目标允许
    mt.convert_targets = {
        ["地面"] = 2 ^ 1,
        ["空中"] = 2 ^ 2,
        ["建筑"] = 2 ^ 3,
        ["守卫"] = 2 ^ 4,
        ["物品"] = 2 ^ 5,
        ["树木"] = 2 ^ 6,
        ["墙"] = 2 ^ 7,
        ["残骸"] = 2 ^ 8,
        ["装饰物"] = 2 ^ 9,
        ["桥"] = 2 ^ 10,
        -- ["未知"]	= 2 ^ 11,
        ["自己"] = 2 ^ 12,
        ["玩家单位"] = 2 ^ 13,
        ["联盟"] = 2 ^ 14,
        ["中立"] = 2 ^ 15,
        ["敌人"] = 2 ^ 16,
        -- ["未知"]	= 2 ^ 17,
        -- ["未知"]	= 2 ^ 18,
        -- ["未知"]	= 2 ^ 19,
        ["可攻击的"] = 2 ^ 20,
        ["无敌"] = 2 ^ 21,
        ["英雄"] = 2 ^ 22,
        ["非-英雄"] = 2 ^ 23,
        ["存活"] = 2 ^ 24,
        ["死亡"] = 2 ^ 25,
        ["有机生物"] = 2 ^ 26,
        ["机械类"] = 2 ^ 27,
        ["非-自爆工兵"] = 2 ^ 28,
        ["自爆工兵"] = 2 ^ 29,
        ["非-古树"] = 2 ^ 30,
        ["古树"] = 2 ^ 31
    }

    -- 技能选项
    mt.options = {
        ["图标可见"] = 2 ^ 0,
        -- 选中后从准心会变成圆面
        ["目标选取图像"] = 2 ^ 1
    }
end

return mt
