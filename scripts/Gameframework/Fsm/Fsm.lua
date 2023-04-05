local State = require "Gameframework.Fsm.FsmState"

local mt = {}
mt.__index = mt
mt.Type = "Fsm"
mt._Name = nil;
mt._Owner = nil
mt._States = { State }
mt._Varialbes = nil
mt._CurrentState = State
mt._CurrentState = nil
mt._CurrentStateTime = 0
mt._IsDestroyed = false;


local allInstance = { mt }
table.remove(allInstance)



function mt:Start(stateType)
    if self._CurrentState ~= nil then
        error("FSM is running, can not start again.")
    end

    local state = self:GetState(stateType)
    if not state then
        error(("FSM '%s' can not start state '%s' which is not exist."):format(self._Name, stateType))
    end

    self._CurrentState = state
    self._CurrentStateTime = 0
    state:OnEnter(self)
end

function mt:HasState(stateType)
    return self._States[stateType] ~= nil
end

function mt:GetState(stateType)
    return self._States[stateType]
end

function mt:ChangeState(stateType)
    if self._CurrentState == nil then
        error("Current state is invalid.")
    end
    local state = self:GetState(stateType)
    if not state then
        error(("FSM '%s' can not change state to '%s' which is not exist."):format(self._Name, stateType))
    end
    self._CurrentState:OnLeave(self)
    self._CurrentStateTime = 0
    self._CurrentState = state
    self._CurrentState:OnEnter(self)
end

function mt:GetData(name)
    return self._Varialbes[name]
end

function mt:SetData(name, value)
    self._Varialbes[name] = value
end


function mt:Update()
    if not self._CurrentState then
        return
    end
    self._CurrentStateTime = self._CurrentStateTime + game.DeltaTime
    self._CurrentState:OnUpdate(self)
end

function mt:Clear()
    if self._CurrentState ~= nil then
        self._CurrentState:OnLeave(self)
    end

    for key, value in pairs(self._States) do
        value:OnDestroy(self)
        self._States[key] = nil
    end

    self._Name = nil
    self._Owner = nil

    for key, value in pairs(self._Varialbes) do
        self._Varialbes[key] = nil
    end

    self._CurrentState = nil
    self._CurrentStateTime = 0
    self._IsDestroyed = true;

    allInstance[self._Name] = nil
end

local Collection = {}
local function PoolGet()
    local count = #Collection
    if count > 0 then
        return table.remove(Collection)
    else
        local t = setmetatable({}, mt)
        t._States = {}
        t._Varialbes = {}
        return t
    end
end
Yuyuko.RefrencePool[mt.Type] = Collection


-- @ 状态机名称, 主人, FsmStates
function mt.Create(name, owner, fsmStates)
    local fsm = PoolGet()
    fsm._Name = name
    fsm._Owner = owner
    fsm._IsDestroyed = false;
    for index, value in ipairs(fsmStates) do
        if (value == nil) then
            error("FSM states is invalid.")
        end
        local statesType = value.Type
        if fsm._States[statesType] then
            error(("FSM '%s' state '%s' is already exist."):format(fsm._Name, statesType))
        end
        fsm._States[statesType] = value
        value:OnInit(fsm)
    end
    allInstance[name] = fsm
    return fsm
end

function mt.Destroy(name)
    Yuyuko.RefrencePool.Push(allInstance[name])
end

function mt.init()
    Yuyuko.TimeLine:Loop(game.FRAME * 1000, function()
        for key, value in pairs(allInstance) do
            value:Update()
        end
    end)
end

return mt
