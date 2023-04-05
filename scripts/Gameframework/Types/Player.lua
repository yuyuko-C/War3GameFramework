local jass = require "jass.common"
local dbg = require "jass.debug"
local Point = require "Gameframework.Types.Point"
local Rect = require "Gameframework.Types.Rect"
local Circle = require "Gameframework.Types.Circle"
local fogmodifier = require "Gameframework.Types.fogmodifier"

local color_word = {}
local function set_color_word()
    -- 注册颜色代码
    color_word[1] = '|cFFFF0303'
    color_word[2] = '|cFF0042FF'
    color_word[3] = '|cFF1CE6B9'
    color_word[4] = '|cFF540081'
    color_word[5] = '|cFFFFFC01'
    color_word[6] = '|cFFFE8A0E'
    color_word[7] = '|cFF20C000'
    color_word[8] = '|cFFE55BB0'
    color_word[9] = '|cFF959697'
    color_word[10] = '|cFF7EBFF1'
    -- color_word[11] = "|cFF106246"
    -- color_word[12] = "|cFF4E2A04"
    color_word[11] = '|cFFFFFC01'
    color_word[12] = '|cFF0042FF'
    color_word[13] = '|cFF282828'
    color_word[14] = '|cFF282828'
    color_word[15] = '|cFF282828'
    color_word[16] = '|cFF282828'
end

local mt = {}
mt.__index = mt
mt.Type = "Player"
mt._ID = 0
mt._Handle = nil
mt._Name = nil
mt._Gold = nil
mt._Lumber = nil
mt._Food = nil
mt._TeamID = nil

local allInstance = { mt }
table.remove(allInstance)


function mt:new(index)
    local t = setmetatable({}, mt)
    t._ID = index
    t._Handle = jass.Player(index - 1)
    t._Name = jass.GetPlayerName(t._Handle)
    t._Gold = jass.GetPlayerState(self._Handle, jass.PLAYER_STATE_RESOURCE_GOLD)
    t._Lumber = jass.GetPlayerState(self._Handle,
        jass.PLAYER_STATE_RESOURCE_LUMBER)
    t._Food = jass.GetPlayerState(self._Handle,
        jass.PLAYER_STATE_RESOURCE_FOOD_USED)
    t._TeamID = jass.GetPlayerTeam(self._Handle) + 1
    return t
end

function mt:__tostring()
    return ('Player:{id:%s,name:%s}'):format(self._id, self:GetName())
end

-- #region 基础

function mt:GetName() return self._Name end

function mt:SetName(name)
    if (not name) or name == "" then return end
    jass.SetPlayerName(self._Handle, name)
    self._Name = name
end

-- 增加金钱
-- 是否抛出加钱事件
function mt:AddGold(gold, flag)
    if gold > 0 and not flag then
        local eventID = Events.PlayerGetGoldArgs.EventID
        local evnetArgs = Events.PlayerGetGoldArgs.Create(self, gold)
        Yuyuko.EventManager.Fire(eventID, evnetArgs)
        Yuyuko.RefrencePool.Push(evnetArgs)
    end
    self._Gold = self._Gold + gold
    jass.SetPlayerState(self._Handle, jass.PLAYER_STATE_RESOURCE_GOLD,
        self._Gold)
end

-- 获取金钱
function mt:GetGold() return self._Gold end

-- 增加木材
-- 是否抛出加木材事件
function mt:AddLumber(lumber, flag)
    if lumber > 0 and not flag then
        local eventID = Events.PlayerGetLumberArgs.EventID
        local evnetArgs = Events.PlayerGetLumberArgs.Create(self, lumber)
        Yuyuko.EventManager.Fire(eventID, evnetArgs)
        Yuyuko.RefrencePool.Push(evnetArgs)
    end
    self._Lumber = self._Lumber + lumber
    jass.SetPlayerState(self._Handle, jass.PLAYER_STATE_RESOURCE_LUMBER,
        self._lumber)
end

-- 获取木材
function mt:GetLumber() return self._Lumber end

-- 增加人口
-- 是否抛出加人口事件
function mt:AddFood(food, flag)
    if food > 0 and not flag then
        local eventID = Events.PlayerGetFoodEventArgs.EventID
        local evnetArgs = Events.PlayerGetFoodEventArgs
            .Create(self, food)
        Yuyuko.EventManager.Fire(eventID, evnetArgs)
        Yuyuko.RefrencePool.Push(evnetArgs)
    end
    self._Food = self._Food + food
    jass.SetPlayerState(self._Handle, jass.PLAYER_STATE_RESOURCE_FOOD_USED,
        self._Food)
end

-- 获取人口
function mt:GetFood() return self._Food end

-- 命令玩家选中单位
--	单位
function mt:SelectUnit(unit)
    if self:IsLocalPlayer() then
        jass.ClearSelection()
        jass.SelectUnit(unit._Handle, true)
    end
end

-- 命令玩家加选单位
--	单位
function mt:AddUnitSelect(unit)
    if self:IsLocalPlayer() then jass.SelectUnit(unit._Handle, true) end
end

-- 命令玩家取消选择某单位
--	单位
function mt:RemoveUnitSelect(unit)
    if self:IsLocalPlayer() then jass.SelectUnit(unit._Handle, false) end
end

---允许玩家使用技能
---@param abilityID number
---@param flag boolean
function mt:SetAbilityAvailable(abilityID, flag)
    if abilityID then
        jass.SetPlayerAbilityAvailable(self._Handle, abilityID, flag)
    end
end

-- #endregion

-- #region 条件判断

-- 是否是玩家
function mt:IsPlayer()
    return jass.GetPlayerController(self._Handle) == jass.MAP_CONTROL_USER and
        jass.GetPlayerSlotState(self._Handle) ==
        jass.PLAYER_SLOT_STATE_PLAYING
end

-- 是否是裁判
function mt:isObserver() return jass.IsPlayerObserver(self._Handle) end

-- 是否是本地玩家
function mt:IsLocalPlayer()
    return self._Handle == jass.GetLocalPlayer()
end

-- 目标点对我是否可见
function mt:IsVisible(point)
    return jass.IsVisibleToPlayer(point.X, point.Y, self._Handle)
end

-- 单位是否可见
function mt:IsUnitVisiable(destUnit)
    return jass.IsUnitVisible(destUnit._Handle, self._Handle)
end

-- 是否是敌人
function mt:IsEnemy(dest) return self:GetTeam() ~= dest:GetTeam() end

-- 是否是友军
function mt:IsAlly(dest) return self:GetTeam() == dest:GetTeam() end

-- #endregion

-- #region 信息传递

-- 发送消息
--	消息内容
--	[持续时间]
function mt:SendMsg(text, keepTime)
    jass.DisplayTimedTextToPlayer(self._Handle, 0, 0, keepTime or 60, text)
end

-- 显示系统警告
--	警告内容
function mt:ShowSysWarning(msg)
    local sys_sound = jass.CreateSoundFromLabel('InterfaceError', false, false,
        false, 10, 10)
    if (jass.GetLocalPlayer() == self._Handle) then
        if (msg ~= '') and (msg ~= nil) then
            jass.ClearTextMessages()
            jass.DisplayTimedTextToPlayer(self._Handle, 0.5, -1, 2,
                '|cffffcc00' .. msg .. '|r')
        end
        jass.StartSound(sys_sound)
    end
    jass.KillSoundWhenDone(sys_sound)
end

-- 小地图信号
--	信号位置
--	信号时间
--	[红色]
--	[绿色]
--	[蓝色]
function mt:PingMinimap(point, time, red, green, blue, flag)
    if self:IsLocalPlayer() then
        jass.PingMinimapEx(point.X, point.Y, time, red or 0, green or 255,
            blue or 0, not (not flag))
    end
end

-- 清空屏幕显示
function mt:ClearMsg()
    if self:IsLocalPlayer() then jass.ClearTextMessages() end
end

-- #endregion

-- #region 镜头

-- 设置镜头位置
function mt:SetCamera(point, time)
    if self:IsLocalPlayer() then
        local x, y
        if point then
            x, y = point:Unpack()
        else
            x, y = jass.GetCameraTargetPositionX(),
                jass.GetCameraTargetPositionY()
        end
        if time then
            jass.PanCameraToTimed(x, y, time)
        else
            jass.SetCameraPosition(x, y)
        end
    end
end

-- 设置镜头抖动
function mt:SetCameraEQNoise(magnitude)
    local richter = math.clamp(magnitude, 2, 5)
    if self:IsLocalPlayer() then
        jass.CameraSetTargetNoiseEx(magnitude * 2, magnitude * 10 ^ richter, true)
        jass.CameraSetSourceNoiseEx(magnitude * 2, magnitude * 10 ^ richter, true)
    end
end

-- 停止镜头抖动
function mt:ClearCameraEQNoise()
    jass.CameraSetTargetNoise(0, 0)
    jass.CameraSetSourceNoise(0, 0)
end

-- 设置镜头属性
--	镜头属性
--	数值
--	[持续时间]
function mt:SetCameraField(key, value, time)
    if self:IsLocalPlayer() then
        jass.SetCameraField(jass[key], value, time or 0)
    end
end

-- 获取镜头属性
--	镜头属性
function mt:GetCameraField(key)
    return math.deg(jass.GetCameraField(jass[key]))
end

-- 设置镜头目标
function mt:SetCameraTarget(target, x, y)
    if self:IsLocalPlayer() then
        jass.SetCameraTargetController(target and target.handle or 0, x or 0,
            y or 0, false)
    end
end

-- 旋转镜头
function mt:RotateCamera(_point, angle, time)
    if self:IsLocalPlayer() then
        local x, y = _point:get()
        jass.SetCameraRotateMode(x, y, math.rad(angle), time)
    end
end

-- 获取镜头位置
function mt:GetCamera()
    return Point.Create(jass.GetCameraTargetPositionX(),
        jass.GetCameraTargetPositionY())
end

-- 设置镜头可用区域
function mt:SetCameraBounds(...)
    if self:IsLocalPlayer() then
        local minX, minY, maxX, maxY
        if select('#', ...) == 1 then
            local rct = Rect.GetRectByName(...)
            minX, minY, maxX, maxY = rct:Unpack()
        else
            minX, minY, maxX, maxY = ...
        end
        jass.SetCameraBounds(minX, minY, minX, maxY, maxX, maxY, maxX, minY)
    end
end

-- 创建可见度修正器
--	圆心
--	半径
--	[是否可见]
--	[是否共享]
--	[是否覆盖单位视野]
function mt:CreateFogmodifier(point, radius, ...)
    return fogmodifier.new(self, Circle.Create(point, radius), ...)
end

-- 滤镜
function mt:CinematicFilter(data)
    jass.SetCineFilterTexture(data.file or
        [[ReplaceableTextures\CameraMasks\DreamFilter_Mask.blp]])
    jass.SetCineFilterBlendMode(jass.BLEND_MODE_BLEND)
    jass.SetCineFilterTexMapFlags(jass.TEXMAP_FLAG_NONE)
    jass.SetCineFilterStartUV(0, 0, 1, 1)
    jass.SetCineFilterEndUV(0, 0, 1, 1)
    if data.start then
        jass.SetCineFilterStartColor(data.start[1] * 2.55, data.start[2] * 2.55,
            data.start[3] * 2.55, data.start[4] * 2.55)
    end
    if data.finish then
        jass.SetCineFilterEndColor(data.finish[1] * 2.55, data.finish[2] * 2.55,
            data.finish[3] * 2.55, data.finish[4] * 2.55)
    end
    jass.SetCineFilterDuration(data.time)
    if self:IsLocalPlayer() then jass.DisplayCineFilter(true) end

    function data:remove()
        if self:IsLocalPlayer() then jass.DisplayCineFilter(false) end
    end

    return data
end

-- #endregion

-- #region 结盟

-- 结盟
function mt:SetAllianceSetting(dest, alliaSetting, flag)
    jass.SetPlayerAlliance(self._Handle, dest._Handle, alliaSetting, flag)
end

-- 单位共享
--	[显示头像]
function mt:ShareControlTo(dest, flag)
    jass.SetPlayerAlliance(self._Handle, dest._Handle, 6, true)
    if flag then
        jass.SetPlayerAlliance(self._Handle, dest._Handle, 7, true)
    end
end

-- 是否单位共享
function mt:IsShareContrlTo(player)
    return jass.GetPlayerAlliance(self._Handle, player._Handle, 6)
end

-- 结盟的常用设置
function mt:SetAllianceSimple(dest, flag)
    self:SetAllianceSetting(dest, 0, flag)  -- ALLIANCE_PASSIVE（结盟，不侵犯）
    self:SetAllianceSetting(dest, 1, false) -- ALLIANCE_HELP_REQUEST（救援请求）
    self:SetAllianceSetting(dest, 2, false) -- ALLIANCE_HELP_RESPONSE（救援回应）
    self:SetAllianceSetting(dest, 3, flag)  -- ALLIANCE_SHARED_XP（共享经验）
    self:SetAllianceSetting(dest, 4, flag)  -- ALLIANCE_SHARED_SPELLS（盟友魔法锁定）
    self:SetAllianceSetting(dest, 5, flag)  -- ALLIANCE_SHARED_VISION（共享视野）

    -- self:setAlliance(dest, 6, flag) -- ALLIANCE_SHARED_CONTROL（共享单位）
    -- self:setAlliance(dest, 7, flag) -- ALLIANCE_SHARED_ADVANCED_CONTROL（共享完全控制权）
    -- self:setAlliance(dest, 8, flag) -- ALLIANCE_RESCUABLE（救援）
    -- self:setAlliance(dest, 9, flag) -- ALLIANCE_SHARED_VISION_FORCED（共享视野）
end

-- 队伍
-- 设置队伍
function mt:SetTeam(team_id)
    jass.SetPlayerTeam(self._Handle, team_id - 1)
    self._TeamID = team_id
end

-- 获取队伍
function mt:GetTeam() return self._TeamID end

-- #endregion

-- #region 界面

-- 允许UI
function mt:EnableUserUI()
    if self:IsLocalPlayer() then jass.EnableUserUI(true) end
end

-- 禁止UI
function mt:DisableUserUI()
    if self:IsLocalPlayer() then jass.EnableUserUI(false) end
end

-- 显示界面
--	[转换时间]
function mt:ShowInterface(time)
    if self:IsLocalPlayer() then jass.ShowInterface(true, time or 0) end
end

-- 隐藏界面
--	[转换时间]
function mt:HideInterface(time)
    if self:IsLocalPlayer() then jass.ShowInterface(false, time or 0) end
end

-- 设置昼夜模型
local default_model =
'Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl'
function mt:SetDayModel(model)
    if self:IsLocalPlayer() then
        jass.SetDayNightModels(model or default_model,
            'Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl')
    end
end

-- 强制按键
--	按下的键(字符串'ESC'表示按下ESC键)
function mt:PressKey(key)
    if not self:IsLocalPlayer() then return end

    key = key:upper()

    if key == 'ESC' then
        jass.ForceUICancel()
    else
        jass.ForceUIKey(key)
    end
end

-- #endregion

-- 清点在线玩家
function mt.CountAlive()
    local count = 0
    for i = 1, 16 do if mt[i]:IsPlayer() then count = count + 1 end end
    return count
end

function mt.GetByHandle(handle)
    return allInstance[handle]
end

function mt.GetByIndex(index)
    return allInstance[index]
end

-- 获得本地玩家
function mt.GetLocalPlayer()
    return mt.GetByHandle(jass.GetLocalPlayer())
end

-- 获得触发玩家
function mt.GetTriggerPlayer()
    return mt.GetByHandle(jass.GetTriggerPlayer())
end

function mt.init()
    -- 初始化所有玩家
    for i = 1, 16, 1 do
        local player = mt:new(i)
        mt[i] = player -- 这里是方便外部使用的,函数太长了
        allInstance[player._Handle] = player
        allInstance[i] = player
    end

    -- 保留2个图标位置
    jass.SetReservedLocalHeroButtons(0)

    -- 所有玩家都与16号玩家结盟
    for i = 1, 16 do
        mt[i]:SetAllianceSimple(mt[16], true)
    end

    -- 初始化玩家颜色值
    set_color_word()
end

return mt
