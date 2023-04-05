-- 执行timer在frame帧的全部委托
local function timer_on_tick(timer)
    local timeFrame = timer._FrameList[timer._CurrentFrame]
    -- 如果在当前帧没有委托序列
    if timeFrame == nil then return end
    -- 执行当前帧
    timeFrame:Invoke()
    -- 清空当前帧
    timer._FrameList[timer._CurrentFrame] = nil
    -- 回收此队列
    Yuyuko.RefrencePool.Push(timeFrame)
end

local mt = {}
mt.__index = mt
mt.Type = "TimeLine"
mt._FrameList = nil
mt._CurrentFrame = 0
mt._ScaleFrame = 0 -- 时间尺度影响下的frame，用于计算frame的更新
mt._LastScaleFrame = 0 -- 时间尺度影响下的上一帧
mt._Scale = 1 -- 时间尺度


function mt:Clock() return self._CurrentFrame end

function mt:Size()
    local n = 0
    local frame_queue = self._FrameList
    for frame, timeFrame in pairs(frame_queue) do
        n = n + timeFrame:Size() -- 加上队列里所有action的数量
    end
    return n
end

local TimeAction = require "Gameframework.TimeLine.TimeAction"

function mt:Wait(timeoutFrame, callback)
    local timeout = math.max(math.floor(timeoutFrame) or 1, 1)
    local action_obj = TimeAction.Create(self, timeout, false, callback)
    return action_obj
end

function mt:Loop(timeoutFrame, callback)
    local timeout = math.max(math.floor(timeoutFrame) or 1, 1)
    local action_obj = TimeAction.Create(self, timeout, true, callback)
    return action_obj
end

function mt:Timer(timeoutFrame, count, callback)
    if count == 0 then return self:Wait(timeoutFrame, callback) end
    local t = self:Loop(timeoutFrame, function(timerAction)
        callback(timerAction)
        count = count - 1
        if count <= 0 then timerAction:Remove() end
    end)
    return t
end

function mt:Update()
    self._ScaleFrame = self._ScaleFrame + self._Scale
    local frame_count = self._ScaleFrame // 1 - self._LastScaleFrame // 1
    for i = 1, frame_count, 1 do
        timer_on_tick(self)
        self._CurrentFrame = self._CurrentFrame + 1
        -- print('self._CurrentFrame', self._CurrentFrame, frame_count)
    end
    self._LastScaleFrame = self._ScaleFrame
end

function mt:Clear()
    self._CurrentFrame = 0
    self._ScaleFrame = 0
    self._LastScaleFrame = 0
    self._Scale = 1
    Yuyuko.Time.RemoveUpdateListener(self)
end

local Collection = {}
local function PoolGet()
    local count = #Collection
    if count > 0 then
        return table.remove(Collection)
    else
        local t = setmetatable({}, mt)
        t._FrameList = {}
        Yuyuko.Time.AddUpdateListener(t)
        return t
    end
end
Yuyuko.RefrencePool[mt.Type] = Collection

function mt.Create()
    local timeline = PoolGet()
    return timeline
end

return mt
