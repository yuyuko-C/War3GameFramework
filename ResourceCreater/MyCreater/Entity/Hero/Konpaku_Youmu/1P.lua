local mt = {}
-- 父对象
mt._parent = "Hpal"
-- 名字(非英雄显示在血条上方 英雄显示在经验条里)
mt.Name = "魂魄妖梦"
-- 称谓（仅英雄拥有，显示于面板顶部）
mt.Propernames = "万年受"
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
-- 隐藏英雄图标(0为显示,1为隐藏)
mt.hideHeroBar = 0
-- 隐藏英雄的小地图显示
mt.hideHeroMinMap = 1
-- 移动速度(为0能隐藏了大部分默认面板)
mt.spd = 300
-- 隐藏A键的UI，与移动速度为0结合隐藏所有默认UI
mt.showUI1 = 1
-- 目标允许(设置为别人，残骸，基本不会自动攻击了)
mt.targs1 = 'nonacient'
-- 普通技能设定(默认的背包技能)
mt.abilList = AbilityCreater.GetAbilityList(mt)
-- 英雄技能,(空会使学技能的+号隐藏)

local abilities = {
    AbilityCreater.GetHeroAbilityID(mt, AbilityCreater.KEY_Q, true, "ReplaceableTextures\\CommandButtons\\BTNYM_2_Q.blp"),
    AbilityCreater.GetHeroAbilityID(mt, AbilityCreater.KEY_W, true),
    AbilityCreater.GetHeroAbilityID(mt, AbilityCreater.KEY_E, true),
    AbilityCreater.GetHeroAbilityID(mt, AbilityCreater.KEY_R, true),
    AbilityCreater.GetHeroAbilityID(mt, AbilityCreater.KEY_F, true),
}

mt.heroAbilList = table.concat(abilities, ",")
-- 隐藏英雄死亡信息
mt.hideHeroDeathMsg = 1
-- 骰子数量与面数，保持为1使攻击力稳定
mt.sides1 = 1
mt.dice1 = 1
-- 称谓数量
mt.nameCount = 1
-- 设置移动高度
mt.moveHeight = 0
-- 攻击前摇后腰与施法前摇后摇
-- 攻击伤害触发点在攻击动画的百分比
mt.dmgpt1 = 0.433
-- 攻击动画在执行多少百分比后才允许播放下一段动画
mt.backSw1 = 0.567
-- 魔法生效点在释放动作的百分比
mt.castpt = 0
-- 魔法动画在执行多少百分比后才允许播放下一段动画
mt.castbsw = 0
-- 三维初始值与成长值归零
mt.STR = 0
mt.AGI = 0
mt.INT = 0
mt.STRplus = 0
mt.AGIplus = 0
mt.INTplus = 0


Persistent.RegistHero(mt)
