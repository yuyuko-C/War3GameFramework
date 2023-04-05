local mt = {}
mt.__index = mt
mt.Type = "FsmState"

function mt:OnInit(fsm)

end

function mt:OnEnter(fsm)

end

function mt:OnUpdate(fsm)

end

function mt:OnLeave(fsm)

end

function mt:OnDestroy(fsm)

end

function mt:ChangeState(fsm, stateType)
    fsm:ChangeState(stateType)
end

return mt
