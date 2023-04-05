local jass = require 'jass.common'

-- 音效长度注册(单位:毫秒)
local soundDuration = {}

local mt = {}
mt.__index = mt
mt.Type = "Sound"
mt._Handle = 0
-- 音量[0-1]
mt._Volume = 1
-- 播放速度[0-1]
mt._Pitch = 1


local pool = {}

-- 将音效放入音效池
--	路径名
--	音效
local function PushSound(name, sound)
    local list = pool[name]
    if not list then
        list = {}
        pool[name] = list
    end
    table.insert(list, sound)
end

-- 从音效池取出音效
--	路径名
--	@音效
local function GetSound(name)
    local list = pool[name]
    if not list then
        list = {}
        pool[name] = list
    end
    local count = #list
    if count > 0 then
        return table.remove(list)
    else
        local t = setmetatable({}, mt)
        t._Handle = jass.CreateSound(name, false, false, false, 10, 10, '')
        soundDuration[name] = jass.GetSoundDuration(t._Handle)
        jass.SetSoundChannel(t._Handle, 0)
        jass.SetSoundVolume(t._Handle, 127)
        jass.SetSoundPitch(t._Handle, 1)
        jass.SetSoundDistances(t._Handle, 1250, 1800)
        jass.SetSoundDistanceCutoff(t._Handle, 3000)
        jass.SetSoundConeAngles(t._Handle, 0, 0, 127)
        jass.SetSoundConeOrientation(t._Handle, 0, 0, 0)

        Yuyuko.Log.info('音效创建', name, soundDuration[name])
        return t
    end
end

-- 设置音效长度(毫秒)
function mt:SetSoundDuration(duration)
    jass.SetSoundDuration(self._Handle, duration)
end

-- 设置播放音量[0-1]
function mt:SetSoundVolume(volume)
    self._Volume = volume
    jass.SetSoundVolume(self._Handle, volume * 127)
end

-- 设置播放速度[0-1]
function mt:SetSoundPitch(pitch)
    self._Pitch = pitch
    jass.SetSoundPitch(self._Handle, pitch)
end

function mt:PlayeAttachUnit(unit)
    jass.AttachSoundToUnit(self._Handle, unit._Handle)
    jass.StartSound(self._Handle)
end

function mt:PlayeAtPoint(point)
    jass.SetSoundPosition(self._Handle, point:Unpack())
    jass.StartSound(self._Handle)
end

function mt:PlayToPlayer(player)
    jass.StartSound(self._Handle)
    if not player:IsLocalPlayer() then jass.SetSoundVolume(self._Handle, 0) end
end

function mt.Create(name)
    local t = GetSound(name)
    return t
end

-- 获得武器音效名(感觉没啥用,魔兽会自动处理)
--	目标单位
--	[使用哪一个音效,一共有3个,如果不指定则随机]
--	[武器类型]
function Types.Unit:GetWeaponSound(target, weapon_type, n)
    local weapon_type = weapon_type or self:get_slk 'weapType1'
    local armor = target:get_slk 'armor'
    return [[Sound\Units\Combat\]] .. weapon_type .. armor ..
        (n or math.random(1, 3)) .. '.wav'
end

return mt
