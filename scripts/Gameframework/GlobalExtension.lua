local jass = require "jass.common"
local debug = require 'jass.debug'

-- #region 触发器

function Yuyuko.CreateTrigger(call_back)
    local trg = jass.CreateTrigger()
    debug.handle_ref(trg)
    jass.TriggerAddAction(trg, call_back)
    return trg
end

function Yuyuko.DestroyTrigger(trg)
    jass.DestroyTrigger(trg)
    debug.handle_unref(trg)
end

-- #endregion

-- #region  转换256进制整数

local ids1 = {}
local ids2 = {}

local function id_encode(a)
    local r = ('>I4'):pack(a)
    ids1[a] = r
    ids2[r] = a
    return r
end

local function id_decode(a)
    local r = ('>I4'):unpack(a)
    ids2[a] = r
    ids1[r] = a
    return r
end

---comment
---@param int_id integer
---@return string
function Yuyuko.ID2String(int_id) return ids1[int_id] or id_encode(int_id) end

---comment
---@param str_id string
---@return integer
function Yuyuko.String2ID(str_id) return ids2[str_id] or id_decode(str_id) end

-- #endregion

-- #region 管理器
Yuyuko.AsyncExecuter = require "Gameframework.Base.AsyncExecuter"
Yuyuko.Debugger = require "Gameframework.Base.Debugger"
Yuyuko.Time = require "Gameframework.Base.HardwareTimer"
Yuyuko.LinqList = require "Gameframework.Base.LinqList"
Yuyuko.LocalInput = require "Gameframework.Base.LocalInput"
Yuyuko.Log = require "Gameframework.Base.Log"
Yuyuko.RefrencePool = require "Gameframework.Base.RefrencePool"
Yuyuko.ResourceManager = require "Gameframework.Base.ResourceManager"
Yuyuko.TimeLine = require "Gameframework.TimeLine.TimeLine".Create()
Yuyuko.EventManager = require "Gameframework.War3Event.EventManager"
Yuyuko.MoveAssist = require "Gameframework.Base.MoveAssist"
Yuyuko.FsmState = require "Gameframework.Fsm.FsmState"
Yuyuko.Fsm = require "Gameframework.Fsm.Fsm"
Yuyuko.ProcedureBase = require "Gameframework.Procedure.ProcedureBase"
Yuyuko.ProcedureManager = require "Gameframework.Procedure.ProcedureManager"


-- #endregion

-- #region 类
Types.Ability = require "Gameframework.Types.Ability"
Types.Circle = require "Gameframework.Types.Circle"
Types.Dialog = require "Gameframework.Types.Dialog"
Types.Effect = require "Gameframework.Types.Effect"
Types.FogModifier = require "Gameframework.Types.FogModifier"
Types.Item = require "Gameframework.Types.Item"
Types.Lightning = require "Gameframework.Types.Lightning"
Types.Multiboard = require "Gameframework.Types.Multiboard"
Types.Player = require "Gameframework.Types.Player"
Types.Point = require "Gameframework.Types.Point"
Types.Rect = require "Gameframework.Types.Rect"
Types.Region = require "Gameframework.Types.Region"
Types.Selector = require "Gameframework.Types.Selector"
Types.TextTag = require "Gameframework.Types.TextTag"
Types.Unit = require "Gameframework.Types.Unit"
-- #endregion

-- #region 事件

Events.War3PlayerChatEventArgs = require "Gameframework.War3Event.PlayerEvents.PlayerChatEventArgs"
Events.War3PlayerClickButtonEventArgs = require "Gameframework.War3Event.PlayerEvents.PlayerClickButtonEventArgs"
Events.War3PlayerSelectUnitEventArgs = require "Gameframework.War3Event.PlayerEvents.PlayerSelectUnitEventArgs"


Events.War3UnitLearnAbilityEventArgs = require "Gameframework.War3Event.UnitEvents.Ability.UnitLearnAbilityEventArgs"
Events.War3UnitSpellCastEventArgs = require "Gameframework.War3Event.UnitEvents.Ability.UnitSpellCastEventArgs"
Events.War3UnitSpellChannelEventArgs = require "Gameframework.War3Event.UnitEvents.Ability.UnitSpellChannelEventArgs"
Events.War3UnitSpellEffectEventArgs = require "Gameframework.War3Event.UnitEvents.Ability.UnitSpellEffectEventArgs"
Events.War3UnitSpellEndCastEventArgs = require "Gameframework.War3Event.UnitEvents.Ability.UnitSpellEndCastEventArgs"
Events.War3UnitSpellFinishEventArgs = require "Gameframework.War3Event.UnitEvents.Ability.UnitSpellFinishEventArgs"


Events.War3UnitReviveEventArgs = require "Gameframework.War3Event.UnitEvents.Hero.UnitReviveEventArgs"
Events.War3UnitUpgradeEventArgs = require "Gameframework.War3Event.UnitEvents.Hero.UnitUpgradeEventArgs"


Events.War3UnitOrderEventArgs = require "Gameframework.War3Event.UnitEvents.Issuse.UnitOrderEventArgs"
Events.War3UnitOrderPointEventArgs = require "Gameframework.War3Event.UnitEvents.Issuse.UnitOrderPointEventArgs"
Events.War3UnitOrderTargetEventArgs = require "Gameframework.War3Event.UnitEvents.Issuse.UnitOrderTargetEventArgs"


Events.War3UnitDropItemEventArgs = require "Gameframework.War3Event.UnitEvents.Item.UnitDropItemEventArgs"
Events.War3UnitGetItemEventArgs = require "Gameframework.War3Event.UnitEvents.Item.UnitGetItemEventArgs"
Events.War3UnitSoldItemEventArgs = require "Gameframework.War3Event.UnitEvents.Item.UnitSoldItemEventArgs"
Events.War3UnitUseItemEventArgs = require "Gameframework.War3Event.UnitEvents.Item.UnitUseItemEventArgs"


Events.War3UnitGetDamageEventArgs = require "Gameframework.War3Event.UnitEvents.UnitGetDamageEventArgs"
Events.War3UnitEnterRegionEventArgs = require "Gameframework.War3Event.UnitEvents.UnitEnterRegionEventArgs"
Events.War3UnitLeaveRegionEventArgs = require "Gameframework.War3Event.UnitEvents.UnitLeaveRegionEventArgs"

-- #endregion

-- 启用本地按键事件
Yuyuko.LocalInput.init()
Yuyuko.Debugger.init()
Yuyuko.ResourceManager.init()
Yuyuko.AsyncExecuter.init(game.FRAME * 500)
Yuyuko.MoveAssist.init()
Yuyuko.Fsm.init();

Types.Player.init()
Types.Ability.init()
Types.Point.init()
Types.Rect.init()