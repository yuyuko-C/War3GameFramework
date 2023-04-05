# War3GameFramework ![Github stars](https://img.shields.io/github/stars/yuyuko-C/War3GameFramework.svg) ![Github forks](https://img.shields.io/github/forks/yuyuko-C/War3GameFramework.svg) 
基于 MoeHero 改良研发的魔兽争霸3游戏研发框架,对原框架的各个组件进行了重写，解决了大量问题并规范了许多不规范的写法。

本项目的部分设计思想参考了著名的Unity客户端框架 [EllanJiang/GameFramework](https://github.com/EllanJiang/GameFramework/) .

项目中包含大量注释可自行查看，如有问题请提交issue。



### 项目特性

本次项目设计分为 GameFramework 层和 Gameplay 层. 

GameFramework 在我的设计中定义为通用层, 主要将 War3 的逻辑完全封装. Gameplay 层则是根据开发项目不同需要开发者自行设计的层级.

因此 GameFramework 完全独立于 GamePlay 且基本无需变动, 开发者想要制作自己的游戏在 Gameplay 层编写自己的逻辑即可.

（Gameplay 的实现 Demo 与个人项目紧密相关, 因脱敏考虑，Gameplay文件夹后续放出）




#### 相比于MoeHero

- 将魔兽自带的部分放入GameFramewrok文件夹, 与作者自定义的部分完全隔离, 方便迁移与维护.
- 额外提供了委托/异步/LinqList/LocalInput/Debugger/RefrencePool/FSM/Procedure/ResourceManager/随机抽卡池/搓招池
- 实现了全自定义的战斗系统, 包括属性系统, Buff系统, 伤害系统, 技能系统, AI系统和具备物理特性的弹幕系统
- 实现了完备的高可扩展的的 Buff 系统. Buff 系统具有事件队列, 高优先级 Buff 可对低优先级 Buff 进行事件拦截.
- 将 MoeHero 的 timer 拆分成 HardwareTimer 与 可调整时间尺度的 TimeLine 两部分, 并支持多个 TimeLine.
- 实现了独立魔兽的物编的批量生成与英雄和技能的自动绑定(ResourceCreater)
- 尽可能地保留了代码补全功能, 提升开发效率

#### 相比于魔兽原生

* 可在游戏中读取物编与动态修改物编设置.
* 支持批量生成模板物编，具体功能全由Lua逻辑负责.
* 本地按键事件仅可异步使用. 如需同步需要发送本地命令. 项目已实现按下/抬起/长按/释放四种按键事件. 可轻易实现蓄力攻击与长按攻击.
* 使用JAPI解除诸多系统限制,例如最大生命值,单位转向速度限制,英雄头像可以隐藏,特效可以移动位置和改变角度与大小.



### 配置方法

1. 使用 YDWE 关联地图文件和 War3
2. 运行 LuaTool.exe 生成 RSA 秘钥对, 将 e, n, d 填写到 scripts/(RSAConfig).lua 文件中
3. 在 ResourceCreater/MyCreater/Entity 编写物编后运行 LuaTool.exe 生成 `require` 所有文件
4. 运行 scripts/ResourceCreater/Executer.lua 生成物编后打包
5. 在 scripts/Gameplay/Entity 配置好逻辑后运行 LuaTool.exe 生成 `require` 所有文件.
6. 点击运行




### 项目开发环境

* VSCode
  * Lua v3.6.16
  * Lua Debug v1.61.0
  * Tasks v0.13.1

* YDWE 1.32.13 正式版
