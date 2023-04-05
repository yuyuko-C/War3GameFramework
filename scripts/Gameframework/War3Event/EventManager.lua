local mt = {}
mt.__index = mt


function mt.Subscribe(eventID, func)
    if (eventID == nil or func == nil) then return end
    if (mt[eventID] == nil) then mt[eventID] = {} end
    table.insert(mt[eventID], func)
end

function mt.UnSubscribe(eventID, func)
    if (eventID == nil or func == nil) then return end
    if (mt[eventID] == nil) then return end
    local funcList = mt[eventID]
    for i = #funcList, 1, -1 do
        if (funcList[i] == func) then table.remove(funcList, i) end
    end
end

function mt.Fire(eventID, eventArg)
    if not eventID then return end
    if (mt[eventID] == nil) then return end
    local funcList = mt[eventID]
    for i = #funcList, 1, -1 do funcList[i](eventArg) end
end

local eventID = 0;
function mt.GetEventID()
    eventID = eventID + 1
    return eventID
end

return mt
