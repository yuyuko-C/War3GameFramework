local mt = {}
mt.__index = mt
mt.Type = "PlayerChatPlayerSelectUnitEventArgsEventArgs"
mt.EventID = Yuyuko.EventManager.GetEventID()

function mt:Clear()
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


function mt.Create()
    local eventArgs = PoolGet()
    return eventArgs
end

return mt
