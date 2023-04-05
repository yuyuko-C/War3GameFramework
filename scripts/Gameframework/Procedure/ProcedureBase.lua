local State = require "Gameframework.Fsm.FsmState"

local mt = setmetatable({}, State)
mt.__index = mt
mt.Type = "ProcedureBase"


function mt:OnInit(ProcedureManager)

end

function mt:OnEnter(ProcedureManager)

end

function mt:OnUpdate(ProcedureManager)

end

function mt:OnLeave(ProcedureManager)

end

function mt:OnDestroy(ProcedureManager)

end

return mt
