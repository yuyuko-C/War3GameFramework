local jass = require 'jass.common'


local mt = {}
mt.__index = mt
mt.Type = "TextTag"
mt._Handle = 0
mt._Size = 10
mt._Unit = nil
mt._Color = nil


-- 设置文本
function mt:SetText(string, size)
    jass.SetTextTagText(self._Handle, string, (size or self._Size) * 0.0023)
end

-- 设置位置
function mt:SetPosition(position)
    jass.SetTextTagPos(self._Handle, position:Unpack())
end

---设置颜色[%]
---@param red number
---@param green number
---@param blue number
---@param alpha number
function mt:SetColor(red, green, blue, alpha)
    jass.SetTextTagColor(self._Handle, red * 2.55, green * 2.55, blue * 2.55,
        (alpha or 100) * 2.55)
end

-- 设置速度
function mt:SetVelocity(angle, speed)
    jass.SetTextTagVelocity(self._Handle, speed * math.cos(angle) / 128,
        speed * math.sin(angle) / 128)
end

-- 设置生命周期
function mt:SetLifeTime(fade, life)
    jass.SetTextTagFadepoint(self._Handle, fade)
    jass.SetTextTagLifespan(self._Handle, life)
    jass.SetTextTagPermanent(self._Handle, false)
end

-- 设置永久性
function mt:SetPermanent(permanent)
    jass.SetTextTagPermanent(self._Handle, permanent)
end

function mt:SetVisiable(flag) jass.SetTextTagVisibility(self._Handle, flag) end

function mt:Clear()
    self._Size = 10
end

local Collection = {}
local function PoolGet()
    local count = #Collection
    if count > 0 then
        return table.remove(Collection)
    else
        local t = setmetatable({}, mt)
        -- t._Handle = jass.CreateTextTag()
        return t
    end
end
Yuyuko.RefrencePool[mt.Type] = Collection



function mt.Create(text, point, color, lifeSecond)
    local texttag = PoolGet()
    texttag._Handle = jass.CreateTextTag()
    texttag:SetPosition(point)
    texttag:SetText(text)
    texttag:SetColor(color.red, color.green, color.blue, color.alpha)
    texttag:SetLifeTime(lifeSecond - 1, lifeSecond)
    texttag:SetVisiable(true)
    Yuyuko.TimeLine:Wait(game.FRAME * lifeSecond, function()
        Yuyuko.RefrencePool.Push(texttag)
    end)
    return texttag
end

return mt
