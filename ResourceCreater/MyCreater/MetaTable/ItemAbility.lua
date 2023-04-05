local mt = {}

-- 父对象
mt._parent = "ANcl"
-- 名字(仅编辑器和触发获取名字显示)
mt.Name = "物品技能模板"
-- 是否是物品技能,0代表否,1代表是(不影响其成为物品技能)
mt.item = 1
-- 是否是英雄技能,0代表否,1代表是(不影响其成为英雄技能)
mt.hero = 0
-- 学习所需等级
mt.reqLevel = 1
-- 最大等级
mt.levels = 1
-- 目标允许
mt.targs = ""
-- 效果 - 目标点
mt.EffectArt = ""
-- 效果 - 目标
mt.TargetArt = ""
-- 效果 - 目标附加点1(origin,chest,head)
mt.Targetattach = ""
-- 以下为随最大等级扩充的属性-------
-- 魔法释放间隔
mt.Cool = 0
-- 魔法消耗
mt.Cost = 0
-- 施法持续时间(初始值,每级变化)
mt.DataA = 0
-- 目标类型
mt.DataB = 1
-- 选项
mt.DataC = 1
-- 动作持续时间
mt.DataD =0
-- 使其他技能无效
mt.DataE = 0
-- 基础命令ID(扩充到每个等级)
mt.DataF = ""


return mt
