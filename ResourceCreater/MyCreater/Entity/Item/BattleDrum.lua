local BattleDrumAbility = require "ResourceCreater.MyCreater.Entity.Item.BattleDrumAbility"

local mt = {}
-- 父对象
mt._parent = "ches"
-- 名字(鼠标悬停显示, UI上方显示)
mt.Name = "战鼓"
-- 图标
mt.Art = ""
-- 地上的描述
mt.Description = "地上的描述"
-- 物品栏的描述
mt.Ubertip = "物品栏的描述"
-- 绑定的技能ID
mt.abilList = Persistent.RegistAbility(BattleDrumAbility, true)
-- CD间隔组(空也是一个间隔组)
mt.cooldownID = ""
-- 使用次数
mt.uses = 0
-- 使用完会消失
mt.perishalbe = 0
-- 主动使用(直接决定了物品能否点击,触发使用物品命令的前提是触发了物品佩戴的技能)
mt.usable = 0
-- 黄金消耗
mt.goldcost = 0
-- 可以被抵押
mt.pawnable = 1

Persistent.RegistItem(mt)
