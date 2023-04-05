local jass = require 'jass.common'
local dbg = require 'jass.debug'


-- 这个区域可以是由多片不连续的区域组成, 区域没有固定的位置
local mt = {}
mt.__index = mt
mt.Type = "Region"
mt._Handle = 0         -- 句柄
mt._EnterTrigger = nil -- 进入区域触发器
mt._LeaveTrigger = nil -- 离开区域触发器


-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

local allInstance = { mt }
table.remove(allInstance)

-- 在不规则区域中添加/移除区域
--	region = region + other
function mt:__add(other)
    if other.Type == 'Rect' then
        -- 添加矩形区域
        jass.RegionAddRect(self._Handle, other:ToJRect())
        table.insert(self._Ranges, other)
    elseif other.Type == 'Point' then
        -- 添加单元点
        jass.RegionAddCell(self._Handle, other:Unpack())
        table.insert(self._Ranges, other)
    elseif other.Type == 'Circle' then
        -- 添加圆形
        local x, y, r = other:Unpack()
        local p0 = other:Center()
        for x = x - r, x + r + 32, 32 do
            for y = y - r, y + r + 32, 32 do
                local p = Types.Point.Create(x, y)
                if p * p0 <= r + 16 then
                    jass.RegionAddCell(self._Handle, x, y)
                end
            end
        end
        table.insert(self._Ranges, other)
    else
        jass.RegionAddCell(self._Handle, other:Center():Unpack())
        table.insert(self._Ranges, other)
    end

    return self
end

--	region = region - other
function mt:__sub(other)
    if other.Type == 'Rect' then
        -- 添加矩形区域
        jass.RegionClearRect(self._Handle, other:ToJRect())
    elseif other.Type == 'Point' then
        -- 移除单元点
        jass.RegionClearCell(self._Handle, other:Unpack())
    elseif other.Type == 'Circle' then
        -- 移除圆形
        local x, y, r = other:Unpack()
        local p0 = other:Center()
        for x = x - r, x + r + 32, 32 do
            for y = y - r, y + r + 32, 32 do
                local p = Types.Point.Create(x, y)
                if p * p0 <= r + 16 then
                    jass.RegionClearCell(self._Handle, x, y)
                end
            end
        end
    else
        jass.RegionClearCell(self._Handle, other:Center():Unpack())
    end

    local index = Yuyuko.LinqList.Index(self._Ranges,
        function(x) return x == other end)
    if index then table.remove(self._Ranges, index) end

    return self
end

function mt:Clear()
    allInstance[self._Handle] = nil
    jass.RemoveRegion(self._Handle)
    if self._EnterTrigger then Yuyuko.DestroyTrigger(self._EnterTrigger) end
    if self._LeaveTrigger then Yuyuko.DestroyTrigger(self._LeaveTrigger) end
    dbg.handle_unref(self._Handle)
    self._Handle = 0
    self._EnterTrigger = nil
    self._LeaveTrigger = nil
end

function mt.GetByHandle(handle)
    return allInstance[handle]
end

-- 获得触发区域
function mt.GetTriggerRegion()
    return mt.GetByHandle(jass.GetTriggeringRegion())
end

local Collection = {}
local function PoolGet()
    local count = #Collection
    if count > 0 then
        return table.remove(Collection)
    else
        local t = setmetatable({}, mt)
        t._Handle = jass.CreateRegion()
        dbg.handle_ref(t._Handle)
        t._Units = {}
        return t
    end
end
Yuyuko.RefrencePool[mt.Type] = Collection

-- 创建矩形区域
---mt.Create(多个区域:circle,rect,point)
function mt.Create(...)
    local region = PoolGet()


    -- 注册区域事件触发器
    region._EnterTrigger = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitEnterRegionEventArgs.EventID, nil)
    end)
    jass.TriggerRegisterEnterRegion(region._EnterTrigger, region._Handle, nil)

    region._LeaveTrigger = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitLeaveRegionEventArgs.EventID, nil)
    end)
    jass.TriggerRegisterLeaveRegion(region._LeaveTrigger, region._Handle, nil)



    allInstance[region._Handle] = region
    ---@diagnostic disable-next-line: cast-local-type
    for _, rct in ipairs { ... } do region = region + rct end
    return region
end

return mt
