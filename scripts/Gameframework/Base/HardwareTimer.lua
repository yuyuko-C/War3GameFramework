-- 硬件级别的刷新时间, 永远不变
local jass = require "jass.common"

local mt = {}
mt.__index = mt

local IUpdatables = {}

local frame = 0
local jtimer = jass.CreateTimer()
jass.TimerStart(jtimer, 0.01, true, function()
    -- 每次调用执行delta次
    for i = 1, game.Delta, 1 do
        frame = frame + 1
        Yuyuko.LinqList.Foreach(IUpdatables, function(x) x:Update(); end)
    end
end)

function mt.FrameCount() return frame end

function mt.AddUpdateListener(updatable)
    local index = Yuyuko.LinqList.Index(IUpdatables,
                                        function(x) return x == updatable end)
    if not index then table.insert(IUpdatables, updatable) end
end

function mt.RemoveUpdateListener(updatable)
    local index = Yuyuko.LinqList.Index(IUpdatables,
                                        function(x) return x == updatable end)
    if index then table.remove(IUpdatables, index) end
end

return mt
