local jass = require "jass.common"

Yuyuko = {}
Types = {}
Events = {}
require "Gameframework.Utils.math"
require "Gameframework.GlobalExtension"
require "Gameframework.Utils.Sync"



local function RegUnitIssuseTrigger()
    -- 发布无目标命令事件
    local j_trg = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitOrderEventArgs.EventID, nil)
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(j_trg, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_UNIT_ISSUED_ORDER, nil)
    end

    -- 发布目标命令事件
    local j_trg = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitOrderTargetEventArgs.EventID, nil)
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(j_trg, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, nil)
    end

    -- 发布点命令事件
    local j_trg = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitOrderPointEventArgs.EventID, nil)
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(j_trg, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, nil)
    end
end

local function RegUnitAbilityTirgger()
    -- 单位学习技能事件
    local trig = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitLearnAbilityEventArgs.EventID, nil)
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(trig, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_HERO_SKILL, nil)
    end

    -- 单位准备释放技能
    local trig = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitSpellChannelEventArgs.EventID, nil)
        -- print("单位准备释放技能")
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(trig, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_UNIT_SPELL_CHANNEL,
            nil)
    end

    -- 单位开始释放技能
    local trig = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitSpellCastEventArgs.EventID, nil)
        -- print("单位开始释放技能")
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(trig, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_UNIT_SPELL_CAST,
            nil)
    end

    -- 单位停止释放技能
    local trig = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitSpellEndCastEventArgs.EventID, nil)
        -- print("单位停止释放技能")
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(trig, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_UNIT_SPELL_ENDCAST,
            nil)
    end


    -- 单位发动技能效果
    local trig = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitSpellEffectEventArgs.EventID, nil)
        -- print("单位发动技能效果")
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(trig, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_UNIT_SPELL_EFFECT,
            nil)
    end

    -- 单位释放技能结束
    local trig = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitSpellFinishEventArgs.EventID, nil)
        -- print("单位释放技能结束")
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(trig, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_UNIT_SPELL_ENDCAST,
            nil)
    end
end

local function RegUnitItemTrigger()
    -- 获得物品
    local j_trg = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitGetItemEventArgs.EventID, nil)
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(j_trg, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_UNIT_PICKUP_ITEM,
            nil)
    end

    -- 丢弃物品
    local j_trg = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitDropItemEventArgs.EventID, nil)
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(j_trg, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_UNIT_DROP_ITEM,
            nil)
    end

    -- 使用物品
    local j_trg = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitUseItemEventArgs.EventID, nil)
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(j_trg, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_UNIT_USE_ITEM, nil)
    end

    -- 售出物品
    local j_trg = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitSoldItemEventArgs.EventID, nil)
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(j_trg, Types.Player[i]._Handle,
            jass.EVENT_UNIT_SELL_ITEM, nil)
    end
end

local function RegUnitHeroTrigger()
    -- 英雄升级事件
    local trig = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitUpgradeEventArgs.EventID, nil)
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(trig, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_HERO_LEVEL,
            nil)
    end

    -- 英雄复活事件
    local trig = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3UnitUpgradeEventArgs.EventID, nil)
    end)
    for i = 1, 13 do
        jass.TriggerRegisterPlayerUnitEvent(trig, Types.Player[i]._Handle,
            jass.EVENT_PLAYER_HERO_REVIVE_FINISH,
            nil)
    end
end

local function RegPlayerTrigger()
    -- 注册玩家聊天和点击单位事件
    local chatTrig = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3PlayerChatEventArgs.EventID, nil)
    end)
    for i = 1, 13, 1 do
        jass.TriggerRegisterPlayerChatEvent(chatTrig, Types.Player[i]._Handle, "", false)
    end

    local selectUnitTrig = Yuyuko.CreateTrigger(function()
        Yuyuko.EventManager.Fire(Events.War3PlayerSelectUnitEventArgs.EventID, nil)
    end)
    for i = 1, 13, 1 do
        jass.TriggerRegisterPlayerUnitEvent(selectUnitTrig, Types.Player[i]._Handle, jass.EVENT_PLAYER_UNIT_SELECTED, nil)
    end
end


RegUnitIssuseTrigger()
RegUnitAbilityTirgger()
RegUnitItemTrigger()
RegUnitHeroTrigger()
RegPlayerTrigger();


-- 定时GC
Yuyuko.TimeLine:Loop(300000 * game.FRAME, function()
    collectgarbage("collect")
    print("gc")
end)
