local mt = {}
mt.__index = mt
mt.Type = "UnitPropertySource"
mt._Avatar = 1
mt._Skill = 0
mt._Buff = 0
mt._Item = 0
mt._MinValue = 0
mt._MaxValue = 0


function mt:__tostring()
    return string.format("%s %s %s %s", self._Avatar, self._Skill, self._Buff,
        self._Item)
end

-- 获取总和
function mt:Value()
    local value = self._Avatar + self._Skill + self._Buff + self._Item
    if value < self._MinValue then
        return self._MinValue
    elseif value > self._MaxValue then
        return self._MaxValue
    else
        return value
    end
end

function mt:SetRange(min, max)
    self._MinValue = min
    self._MaxValue = max
end

-- 设置值
function mt:SetValue(avatar, skill, item, buff)
    self._Avatar = avatar or 0
    self._Skill = skill or 0
    self._Buff = buff or 0
    self._Item = item or 0
end

-- 添加设置值
function mt:AddValue(avatar, skill, item, buff)
    self._Avatar = self._Avatar + (avatar or 0)
    self._Skill = self._Skill + (skill or 0)
    self._Buff = self._Buff + (buff or 0)
    self._Item = self._Item + (item or 0)
end

function mt:Clear()
    self._Avatar = 0
    self._Skill = 0
    self._Buff = 0
    self._Item = 0
end

local Collection = {}
local function PoolGet()
    local count = #Collection
    if count > 0 then
        return table.remove(Collection)
    else
        return setmetatable({}, mt)
    end
end
Yuyuko.RefrencePool[mt.Type] = Collection



function mt.Create(avatar, skill, item, buff)
    local source = PoolGet()
    source:SetValue(avatar, skill, item, buff)
    return source
end

return mt
