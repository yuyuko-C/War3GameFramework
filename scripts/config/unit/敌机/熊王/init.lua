
yo.ini.unit["熊王"] = setmetatable({
    obj = {
        -- 父对象
        _parent="Hant",
        -- 名字
        Name = "熊王",
        -- 称谓（仅英雄拥有，显示于面板顶部）
        Propernames = "熊王",
        -- 模型路径
        file = [[units\human\Peasant\Peasant]],
        -- 选择圈缩放大小
        scale = 1,
        -- 阴影类型(空字符串,Shadow,ShadowFlyer)
        unitShadow = "",
        -- 游戏左上角的图标
        Art = "",
        -- 碰撞体积(8,16,32,48有效)
        collision = 16,
        -- 单位声音
        unitSound = "",
        -- 隐藏英雄图标,0为显示1为隐藏
        hideHeroBar = 0
    },
    ini = {
        -- 设计信息
        model_source = '东方战姬',
        hero_desinger = '幽幽墨染_樱树花开',
        hero_scripter = '幽幽墨染_樱树花开',

        -- 武器类型
        weapon_type = '太刀',
        -- 种族信息
        category = '半灵',
        -- 妹子
        yuri = true,
        -- 平胸
        pad = true,

        -- 属性
        attribute = {
            -- 初始属性，每级提升属性
            ["最大生命值"] = {2000, 10},
            ["最大魔法值"] = {80, 2},
            ["攻击力"] = {0, 2},
            ["移动速度"] = {400, 2},
            ["攻击间隔"] = {1, -0.005}, -- 最小0.1
            ["攻击速度"] = {100, 0}, -- 最高500（5倍）
            ["攻击范围"] = {1000, 0},

            ["暴击概率"] = {
                ["物理"] = 10,
                ["元素-火"] = 0,
                ["元素-雷"] = 0,
                ["元素-冰"] = 0
            },
            ["暴击倍率"] = {
                ["物理"] = 0,
                ["元素-火"] = 0,
                ["元素-雷"] = 0,
                ["元素-冰"] = 0
            },
            ["增加固伤"] = {
                ["物理"] = 0,
                ["元素-火"] = 0,
                ["元素-雷"] = 0,
                ["元素-冰"] = 0,
                ["全伤"] = 0
            },
            ["增加比伤"] = {
                ["物理"] = 0,
                ["元素-火"] = 0,
                ["元素-雷"] = 0,
                ["元素-冰"] = 0,
                ["全伤"] = 0
            },
            ["减少固伤"] = {
                ["物理"] = 0,
                ["元素-火"] = 0,
                ["元素-雷"] = 0,
                ["元素-冰"] = 0,
                ["全伤"] = 0
            },
            ["减少比伤"] = {
                ["物理"] = 0,
                ["元素-火"] = 0,
                ["元素-雷"] = 0,
                ["元素-冰"] = 0,
                ["全伤"] = 0
            }

        },

        -- AI名字(表结构)
        -- 随机AI     {{{"", "", ""},0.2},{"", "", ""},0.4},{"", "", ""},0.4},}
        random_states = nil,
        -- 周期AI   {{"",1400},{"",1500},{"",3000},}
        period_states = {{"熊王-天崩地裂",100},{"熊王-给你一巴掌",5}},
        -- 事件AI   {"", "", ""}
        event_states = {"冰熊-莫挨老子"}
    }

},  yo.ini.mt_unit)




require "config.unit.敌机.熊王.熊王-天崩地裂"
require "config.unit.敌机.熊王.熊王-给你一巴掌"
require "config.unit.敌机.熊王.冰熊-莫挨老子"