-- 用于异步执行多次操作, 防止某一帧执行大量操作造成卡顿
local mt = {}
mt.__index = mt

-- 容许的时间长度
local MAX_FRAME
-- 最大的切割批次
local MAX_BATCH_COUNT
-- 每批次最大的执行次数
local MAX_BATCH_TIMES = 5
-- 此套逻辑下能处理的最大次数
local MAX_TIMES

function mt.ExecuteAciton(times, action)
    if times > MAX_TIMES then
        error("超过最大次数,当前次数:" .. times)
    end

    -- 计算需要分多少时间段执行
    local batchCount = math.ceil(times / MAX_BATCH_TIMES)
    if batchCount == 1 then
        for i = 1, times, 1 do
            action()
        end
        return
    end

    -- 最大帧数除以批次数得到每批次的延迟帧数
    local delayUnit = MAX_FRAME / batchCount

    for i = 1, batchCount, 1 do
        if i == batchCount then
            -- 最后一个批次
            Yuyuko.TimeLine:Wait(delayUnit * (i - 1), function()
                for j = 1, times - MAX_BATCH_TIMES * (i - 1), 1 do
                    action()
                end
            end)
        else
            Yuyuko.TimeLine:Wait(delayUnit * (i - 1), function()
                for j = 1, MAX_BATCH_TIMES, 1 do action() end
            end)
        end
    end
end

function mt.init(maxframe)
    maxframe = maxframe or game.FRAME * 10000
    MAX_FRAME = maxframe
    MAX_BATCH_COUNT = math.floor(MAX_FRAME / 10)
    MAX_TIMES = MAX_BATCH_COUNT * MAX_BATCH_TIMES
end

return mt
