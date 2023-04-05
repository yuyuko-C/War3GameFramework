local mt = {}

-- 父对象
mt._parent = "ANcl"
-- 名字(仅编辑器和触发获取名字显示)
mt.Name = "技能模板"
-- 学习提示(学习栏充当名字)
mt.Researchtip = "学习提示"
-- 学习提示(学习栏充当说明)
mt.Researchubertip = "学习扩展提示"
-- 图标
mt.Art = ""
-- 学习栏图标(一般是暗图标)
mt.ResearchArt = ""
-- 热键
mt.Hotkey = "Q"
-- 按钮位置 - 普通 (X)
mt.Buttonpos_1 = 0
-- 按钮位置 - 普通 (Y)
mt.Buttonpos_2 = 2
-- 热键 - 学习
mt.Researchhotkey = "Q"
-- 按钮位置 - 研究 (X)
mt.Researchbuttonpos_1 = 0
-- 按钮位置 - 研究 (Y)
mt.Researchbuttonpos_2 = 0
-- 是否是物品技能,0代表否,1代表是(不影响其成为物品技能)
mt.item = 0
-- 是否是英雄技能,0代表否,1代表是(不影响其成为英雄技能)
mt.hero = 1
-- 学习所需等级
mt.reqLevel = 1
-- 最大等级
mt.levels = 10
-- 目标允许
mt.targs = ""
-- 效果 - 目标点
mt.EffectArt = ""
-- 效果 - 目标
mt.TargetArt = ""
-- 效果 - 施法者
mt.CasterArt = ""
-- 效果 - 目标附加点1(origin,chest,head)
mt.Targetattach = ""
-- 以下为随最大等级扩充的属性-------
-- 提示(技能栏充当名字)
mt.Tip = "提示"
-- 提示工具 - 普通 - 扩展(技能栏充当说明)
mt.Ubertip = "扩展提示"
-- 魔法释放间隔
mt.Cool = 0
-- 魔法消耗
mt.Cost = 0
-- 施法持续时间
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
