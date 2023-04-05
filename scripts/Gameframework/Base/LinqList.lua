local mt = {}
mt.__index = mt

function mt.Foreach(list, func)
    local length = #list
    for i = 1, length, 1 do func(list[i]) end
end

function mt.ReverseForeach(list, func)
    local length = #list
    for i = length, 0, -1 do func(list[i]) end
end

function mt.Index(list, func)
    local length = #list
    for i = 1, length, 1 do if (func(list[i])) then return i end end

    return nil
end

function mt.ReverseIndex(list, func)
    local length = #list
    for i = length, 0, -1 do if (func(list[i])) then return i end end
    return nil
end

function mt.Clear(list)
    local length = #list
    for i = length, 0, -1 do table.remove(list, i) end
end

return mt
