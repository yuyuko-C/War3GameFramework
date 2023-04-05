local TimeFrame = require "Gameframework.TimeLine.TimeFrame"

-- 将委托插入到计时器的指定帧队列
local function timer_timeout(timer, timeout_frame, action)
    -- 获取到指定的帧的委托队列
    local timeout_frame = timer._CurrentFrame + timeout_frame
    local timeFrame = timer._FrameList[timeout_frame]
    -- print('timeFrame == nil',timeFrame == nil)
    if timeFrame == nil then
        timeFrame = TimeFrame.Create()
        timer._FrameList[timeout_frame] = timeFrame
    end
    action._TimeLine = timer             -- 设定委托所属计时器
    action._TimeOutFrame = timeout_frame -- 记录委托到期帧数,后续暂停与恢复需要
    timeFrame:AddTimeAciton(action)      -- 将委托加入帧队列
end


local mt = {}
mt.__index = mt
mt.Type = "TimeAction"
mt._TimeLine = nil       -- 动作所属时间轴
mt._Callback = nil       -- 需要执行的函数
mt._TimeOutFrame = nil   -- 所在的计时器帧数
mt._TimeOutLoop = nil    -- 循环间隔帧
mt._PauseRemaining = nil -- 是否暂停
mt._Removed = nil        -- 是否被移除


function mt:GetRemaining()
    -- 已移除的动作无剩余时间
    if (self._Removed) then return 0 end
    -- 如果当前处于暂停状态，直接返回剩余时间
    if (self._RemainingFrame) then return self._RemainingFrame end
    -- 如果动作已经到期,则返回循环时间,若不存在循环时间则返回0
    if (self._TimeOutFrame == self._TimeLine.CurrentFrame) then
        return self._TimeOutLoop or 0
    end
    -- 如果动作未移除未暂停且未到期,则返回到期帧与当前帧的差值
    return self._TimeOutFrame - self._TimeLine.CurrentFrame
end

function mt:Invoke()
    if self._Removed then
        Yuyuko.RefrencePool.Push(self)
        return
    end

    if self._PauseRemaining then return end
    self._Callback(self)

    if (self._TimeOutLoop) then
        timer_timeout(self._TimeLine, self._TimeOutLoop, self)
    else
        Yuyuko.RefrencePool.Push(self)
    end
end

function mt:Remove() self._Removed = true end

function mt:Pause()
    if not self._PauseRemaining then
        self._PauseRemaining = self:GetRemaining()
        -- 获取当前动作到期帧
        local timeFrame = self._TimeLine[self._TimeOutFrame]
        -- 若队列存在,则断开此委托与队列的关系
        if timeFrame then timeFrame:RemoveTimeAciton(self) end
    end
end

function mt:Resume()
    -- 如果动作暂停过
    if self._PauseRemaining then
        -- 将按照剩余时间插入时间队列,并解除暂停标志位
        timer_timeout(self._TimeLine, self._PauseRemaining, self)
        self._PauseRemaining = nil
    end
end

function mt:Clear()
    self._TimeLine = nil
    self._Callback = nil
    self._TimeOutFrame = nil
    self._TimeOutLoop = nil
    self._PauseRemaining = nil
    self._Removed = nil
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


function mt.Create(timer, frame, isLoop, callback)
    local action = PoolGet()
    action._TimeLine = timer
    action._Callback = callback;
    timer_timeout(timer, frame, action)
    if isLoop then action._TimeOutLoop = frame end
    return action
end

return mt
