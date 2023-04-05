local mt = {}
-- 父对象
mt._parent = "ANso"
-- 名字(仅编辑器和触发获取名字显示)
mt.Name = "[控制]沉默"
-- 影响区域
mt.Area = 0.0
-- 魔法效果
mt.BuffID = ""
-- 魔法施放时间间隔
mt.Cool = 0.0
-- 魔法消耗
mt.Cost = 0
-- 伤害值
mt.DataA = -1
-- 伤害周期
mt.DataB = 99999.0
-- 攻击减少
mt.DataC = 0.0
-- 移动速度减少(%)
mt.DataD = 0.0
-- 攻击速度减少(%)
mt.DataE = 0.0
-- 持续时间 - 普通
mt.Dur = 0.0
-- 持续时间 - 英雄
mt.HeroDur = 0.0
-- 效果 - 射弹弧度
mt.Missilearc = 0.0
-- 效果 - 投射物图像
mt.Missileart = ""
-- 效果 - 射弹速度
mt.Missilespeed = 0
-- 施法距离
mt.Rng = 99999.0
-- 英雄技能
mt.hero = 0
-- 等级
mt.levels = 1
-- 种族
mt.race = "human"
-- 目标允许
mt.targs = "ground,air,organic"

return mt