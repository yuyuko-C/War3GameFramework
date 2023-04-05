local jass = require "jass.common"
local japi = require "jass.japi"

local Rect = require "Gameframework.Types.Rect"

local mt = {}
mt.__index = mt
mt.Type = "Item"
mt._ID = nil
mt._Handle = nil
mt._Name = nil
mt._Center = nil
mt._Dropable = true
mt._CreateFrame = nil

local allInstance = { mt }
table.remove(allInstance)
local removedHandles = setmetatable({}, { __mode = "kv" })


function mt:__tostring()
    return ('Item:{name:%s, handle:%s}'):format(self._Name, self._Handle)
end

function mt:InitItemByHandle(handle)
    if (not handle) or (handle == 0) then return false end
    if removedHandles[handle] then return false end
    self._Handle = handle
    self._ID = jass.GetItemTypeId(handle)
    self._Name = jass.GetItemName(handle)
    self._Center = Types.Point.Create(jass.GetItemX(handle),
        jass.GetItemY(handle))
    self:SetDropable(true)
    self._CreateFrame = Yuyuko.Time.FrameCount()

    allInstance[self._Handle] = self
end

-- 设置物品的位置,被持有调用就会使持有单位丢掉物品
function mt:SetCenter(x, y)
    local point = Types.Point.Create(x, y)
    if not point:IsInArea(Rect.Map) then
        Yuyuko.Log.error(mt.Type .. '目标点超出地图范围')
    else
        jass.SetItemPosition(self._Handle, x, y)
    end
    Yuyuko.RefrencePool.Push(point)
end

-- 获得物品的位置, 被持有时物品的位置保持捡起来的位置
function mt:Center()
    self._Center._X = jass.GetItemX(self._Handle)
    self._Center._Y = jass.GetItemY(self._Handle)
    return self._Center
end


-- 获得物品名字
function mt:GetName() return self._Name end

-- 获取使用次数
function mt:GetStack() return jass.GetItemCharges(self._Handle) end

-- 设置使用次数
function mt:SetStack(count) jass.SetItemCharges(self._Handle, count) end

-- 增加使用次数
function mt:AddStack(count) self:SetStack(self:GetStack() + (count or 1)) end

-- 设置是否可丢弃
function mt:SetDropable(flag)
    self._Dropable = flag
    jass.SetItemDroppable(self._Handle, flag)
end

-- 设置图标
function mt:SetIcon(art) japi.EXSetItemDataString(self._ID, 1, art) end

-- 设置购买文本
function mt:SetPhrchaseTip(tip) japi.EXSetItemDataString(self._ID, 2, tip) end

-- 设置物品栏文本
function mt:SetBackpackTip(tip) japi.EXSetItemDataString(self._ID, 3, tip) end

-- 设置名字
function mt:SetName(name)
    self._Name = name
    japi.EXSetItemDataString(self._ID, 4, name)
end

-- 设置地面说明
function mt:SetGroundTip(tip) japi.EXSetItemDataString(self._ID, 5, tip) end

function mt:Clear()
    self._ID = nil
    self._Name = nil
    Yuyuko.RefrencePool.Push(self._Center)
    self._Center = nil
    self._Level = nil
    self._CreateFrame = 0
    jass.RemoveItem(self._Handle)
    mt[self._Handle] = nil
    self._Handle = nil
end

function mt.GetByHandle(handle)
    return allInstance[handle]
end

-- 技能释放目标物品
function mt.GetSpellTargetItem()
    return mt.GetByHandle(jass.GetSpellTargetItem())
end

-- 获取目标命令的目标物品
function mt.GetOrderTargetItem()
    return mt.GetByHandle(jass.GetOrderTargetItem())
end

-- 获得被操作物品
function mt.GetManipulatedItem()
    return mt.GetByHandle(jass.GetManipulatedItem())
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

function mt.Create(itemID, x, y)
    local handle = jass.CreateItem(itemID, x, y)
    local item = PoolGet()
    item:InitItemByHandle(handle)
    return item
end

return mt
