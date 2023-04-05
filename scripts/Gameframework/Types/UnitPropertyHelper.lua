local jass = require 'jass.common'
local japi = require 'jass.japi'

local mt = {}

mt.Variable = {}
mt.Fixed = {}

mt.Variable["HPMAX"] =
    function(self, value) jass.SetWidgetLife(self._Handle, value) end

mt.Variable["MPMAX"] = function(self, value)
    jass.SetUnitState(self._Handle, jass.UNIT_STATE_MANA, value)
end

mt.Fixed["HPMAX"] = function(self, value)
    japi.SetUnitState(self._Handle, jass.UNIT_STATE_MAX_LIFE, value)
end

mt.Fixed["MPMAX"] = function(self, value)
    japi.SetUnitState(self._Handle, jass.UNIT_STATE_MAX_MANA, value)
end

mt.Fixed["攻击力"] = function(self, attack)
    japi.SetUnitState(self._Handle, 0x10, 1)
    japi.SetUnitState(self._Handle, 0x11, 1)
    japi.SetUnitState(self._Handle, 0x12, attack - 1)
end

mt.Fixed["攻击间隔"] = function(self, value)
    japi.SetUnitState(self._Handle, 0x25, value)
end

mt.Fixed["攻击速度"] = function(self, value)
    if value >= 0 then
        japi.SetUnitState(self._Handle, 0x51, 1 + value / 100)
    else
        -- 当攻击速度小于0的时候,每点相当于攻击间隔增加1%
        japi.SetUnitState(self._Handle, 0x51, 1 + value / (100 - value))
    end
end

mt.Fixed["攻击范围"] = function(self, value)
    japi.SetUnitState(self._Handle, 0x16, value)
end

mt.Fixed["移动速度"] = function(self, value)
    jass.SetUnitMoveSpeed(self._Handle, value)
    Yuyuko.MoveAssist.OnUpdateSpeed(self, value)
end

return mt
