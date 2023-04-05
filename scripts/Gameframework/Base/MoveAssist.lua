local mt = {}
mt.__index = mt

local assistGroup = {}
local lastPoint = setmetatable({}, { __mode = 'k' })

local function AddUnit(unit)
    lastPoint[unit] = Types.Point.Create(unit:Center():Unpack())
    table.insert(assistGroup, unit)
end

local function RemoveUnit(unit)
    Yuyuko.RefrencePool.Push(lastPoint[unit])
    lastPoint[unit] = nil
    local index = Yuyuko.LinqList.Index(assistGroup,
        function(x) return x == unit end)
    if index then table.remove(assistGroup, index) end
end

function mt.OnUpdateSpeed(unit, move_speed)
    if move_speed > 522 and not lastPoint[unit] then
        AddUnit(unit)
    elseif move_speed <= 520 and lastPoint[unit] then
        RemoveUnit(unit)
    end
end

local function HasBlockPoint(fromPoint, angle, step)
    --检测前方300码是否有不可通行区域
    for i = 32, 32 * step, 32 do
        local p = fromPoint - { angle, i }
        if p:IsBlock() then
            return true
        end
        Yuyuko.RefrencePool.Push(p)
    end
    return false
end


local function Update(action)
    for _, unit in ipairs(assistGroup) do
        local last = lastPoint[unit]
        local now = unit:Center()
        -- 两点距离 / 游戏帧率
        local speed = now * last / game.FRAME
        -- 限制在行走时的速度, 避免位移技能也进行加成
        if speed > 520 and speed < 522 then
            if unit._Switches.AllowMove then
                local angle = last / now
                local distance = unit:GetProperty("移动速度")._FixedValue * game.FRAME
                local targetPoint = last - { angle, distance }
                local hasBlock = HasBlockPoint(unit:Center(), angle, 100)
                if not hasBlock then
                    angle = math.deg(unit:Center() / unit._TargetPoint)
                    if angle < 0 then
                        angle = angle + 360
                    end
                    unit:SetFacing(angle, true)
                else

                end
                unit:SetCenter(targetPoint._X, targetPoint._Y, true)
                lastPoint[unit]:CopyFrom(targetPoint)
                Yuyuko.RefrencePool.Push(targetPoint)
            end
        else
            lastPoint[unit]:CopyFrom(now)
        end
    end
end

function mt.init()
    Yuyuko.TimeLine:Loop(game.FRAME * 1000, Update)
end

return mt
