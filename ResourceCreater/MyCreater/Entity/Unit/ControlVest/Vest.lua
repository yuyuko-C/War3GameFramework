local Silence = require "ResourceCreater.MyCreater.Entity.Unit.ControlVest.Silence"

local mt = {}
-- 父对象
mt._parent = "hpea"
-- 名字(非英雄显示在血条上方 英雄显示在经验条里)
mt.Name = "控制马甲"
-- 模型路径
mt.file = [[units\human\HeroPaladin\HeroPaladin]]
-- 模型缩放
mt.modelScale = 1
-- 选择圈缩放大小
mt.scale = 1
-- 阴影类型(空字符串ShadowFlyer)
mt.unitShadow = ""
-- 游戏左上角的图标
mt.Art = ""
-- 碰撞体积(0,8,16,32,48有效)
mt.collision = 0
-- 单位声音
mt.unitSound = ""
-- 隐藏小地图显示
mt.hideOnMinMap = 0
-- 移动速度(为0能隐藏了大部分默认面板)
mt.spd = 0
-- 转身速度
mt.turnRate = 0
-- 隐藏A键的UI，与移动速度为0结合隐藏所有默认UI
mt.showUI1 = 0
-- 目标允许(设置为非自己，残骸，基本不会自动攻击了)
mt.targs1 = 'notself,debris'
-- 普通技能设定(默认的背包技能)
mt.abilList = Persistent.RegistAbility(Silence, true)
-- 骰子数量与面数，保持为1使攻击力稳定
mt.sides1 = 1
mt.dice1 = 1
-- 设置移动高度
mt.moveHeight = 0
-- 攻击前摇后腰与施法前摇后摇
-- 攻击伤害触发点在攻击动画的百分比
mt.dmgpt1 = 0.0
-- 攻击动画在执行多少百分比后才允许播放下一段动画
mt.backSw1 = 0.0
-- 魔法生效点在释放动作的百分比
mt.castpt = 0
-- 魔法动画在执行多少百分比后才允许播放下一段动画
mt.castbsw = 0
-- 科技树-使用科技
mt.upgrades = ""
-- 科技树-可建造建筑
mt.Builds = ""


Persistent.RegistUnit(mt)
