local mt = {}

-- 父对象
mt._parent = "Aspb"
-- 现阶段只支持程序分配
mt.ID = "字母ID"
-- 名字(仅编辑器和触发获取名字显示)
mt.Name = "技能魔法书"
-- 图标
mt.Art = ""
-- 热键
mt.Hotkey = ""
-- 按钮位置 - 普通 (X)
mt.Buttonpos_1 = 2
-- 按钮位置 - 普通 (Y)
mt.Buttonpos_2 = 1
-- 是否是物品技能,0代表否,1代表是(不影响其成为物品技能)
mt.item = 0
-- 是否是英雄技能,0代表否,1代表是(不影响其成为英雄技能)
mt.hero = 0
-- 学习所需等级
mt.reqLevel = 0
-- 最大等级(魔法书最大等级只需要是1)
mt.levels = 1
-- 魔法释放间隔(初始值,每级变化)
mt.Cool = 0
-- 魔法消耗(初始值,每级变化)
mt.Cost = 0
-- 法术列表
mt.DataA = ""
-- 共享法术CD间隔(0代表否,1代表是)
mt.DataB = 1
-- 最小法术数量
mt.DataC = 1
-- 最大法术数量
mt.DataD = 12
-- 基础命令ID(基础命令ID一致会被合并)
mt.DataE = ""

return mt
