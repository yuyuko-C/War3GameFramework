local mt = {}
mt.__index = mt
mt.Type = "Action"
mt.EventID = Yuyuko.EventManager.GetEventID()
mt._List = nil


function mt:Invoke(obj)
    Yuyuko.LinqList.Foreach(self._List, function(x) x(obj) end)
end

function mt:Add(callback)
    local index = Yuyuko.LinqList.Index(self._List,
        function(x) return x == callback end)
    if not index then table.insert(self._List, callback) end
end

function mt:Remove(callback)
    local index = Yuyuko.LinqList.Index(self._List,
        function(x) return x == callback end)
    if index then table.remove(self._List, index) end
end

function mt:Clear()
end

local Collection = {}
local function PoolGet()
    local count = #Collection
    if count > 0 then
        return table.remove(Collection)
    else
        local t = setmetatable({}, mt)
        t._List = {}
        return t
    end
end
Yuyuko.RefrencePool[mt.Type] = Collection


function mt.Create()
    local action = PoolGet()
    return action
end

return mt
