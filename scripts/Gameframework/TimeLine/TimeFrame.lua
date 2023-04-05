local mt = {}
mt.__index = mt
mt.Type = "TimeFrame"
mt._List = nil


function mt:Size() return #self._List end

function mt:AddTimeAciton(action)
    local index = Yuyuko.LinqList.Index(self._List,
        function(x) return x == action end)
    if not index then table.insert(self._List, action) end
end

function mt:RemoveTimeAciton(action)
    local index = Yuyuko.LinqList.ReverseIndex(self._List, function(x)
        return x == action
    end)
    if index then table.remove(self._List, index) end
end

function mt:Invoke()
    -- 执行当前帧的全部委托并清空当前帧的全部委托
    for i = 0, #self._List do
        local action = self._List[i]
        if action then action:Invoke() end
        self._List[i] = nil
    end
    -- 此时当前帧执行完毕
end

function mt:Clear() Yuyuko.LinqList.Clear(self._List) end

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


function mt.Create() return PoolGet() end

return mt
