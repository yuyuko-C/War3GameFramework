local mt = {}
mt.__index = mt
mt.Type = "RefrencePool"

function mt.Push(obj)
    local collection = mt[obj.Type]
    if (collection == nil) then
        error('未注册的类型:' .. (obj.Type or 'nil'))
        return
    end
    obj:Clear()
    table.insert(collection, obj)
end

return mt
