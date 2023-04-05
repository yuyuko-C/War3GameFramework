local mt = {}
mt.__index = mt
mt.Type =  "UnitSpellChannelEventArgs"
mt.EventID = Yuyuko.EventManager.GetEventID()
mt._Unit = nil

function mt:Clear()
    self._Unit = nil
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



function mt.Create(unit)
    local eventArgs = PoolGet()
    eventArgs._Unit = unit
    return eventArgs
end

return mt
