local Fsm = require "Gameframework.Fsm.Fsm"

local mt = {}
mt.__index = mt
mt.Type = "ProcedureManager"
mt._ProcedureFsm = Fsm



function mt.CurrentProcedure()
    return mt._ProcedureFsm._CurrentState
end

function mt.CurrentProcedureTime()
    return mt._ProcedureFsm._CurrentStateTime
end

function mt.StartProcedure(procedureType)
    mt._ProcedureFsm:Start(procedureType)
end

function mt.HasProcedure(procedureType)
    return mt._ProcedureFsm:HasState(procedureType)
end

function mt.GetProcedure(procedureType)
    return mt._ProcedureFsm:GetState(procedureType)
end

function mt.Initialize(procedures)
    mt._ProcedureFsm = Fsm.Create("ProcedureManager", mt, procedures)
end

return mt
