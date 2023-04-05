local jass = require 'jass.common'
local debug = require 'jass.debug'

local mt = {}
mt.__index = mt
mt.Type = "FogModifier"
mt._Handle = 0

-- 启用修正器
function mt:Enable()
    jass.FogModifierStart(self._Handle)
    return self
end

-- 暂停修正器
function mt:Disable()
    jass.FogModifierStop(self._Handle)
    return self
end

function mt:Clear()
    jass.DestroyFogModifier(self._Handle)
    debug.handle_unref(self._Handle)
    self._Handle = nil
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


-- 创建可见度修正器
--	玩家
--	位置
--	[是否可见]
--	[是否共享]
--	[是否覆盖单位视野]
function mt.Create(player, area, see, share, over)
    local fogmodifier = PoolGet()

    -- 默认可见
    see = see == false and 2 or 4

    -- 默认共享视野
    share = share ~= false and true or false

    -- 是否覆盖单位视野
    over = over and true or false

    local handle
    if area.Type == 'Rect' then
        handle = jass.CreateFogModifierRect(player._Handle, see,
            Types.Rect.ToJRect(area), share,
            over)
    elseif area.Type == 'Circle' then
        local x, y, r = area:Unpack()
        handle = jass.CreateFogModifierRadius(player.handle, see, x, y, r,
            share, over)
    end
    fogmodifier._Handle = handle
    debug.handle_ref(handle)
    jass.FogModifierStart(handle)
    return fogmodifier
end

return mt
