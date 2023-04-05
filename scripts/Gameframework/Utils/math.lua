-- 计算2个角度之间的夹角
--	@夹角[0, 180]
--	@旋转方向(-1 = 逆时针旋转, 1 = 顺时针旋转)
function math.math_angle(r1, r2)
    local r = (r1 - r2) % 360
    if r >= 180 then
        return 360 - r, -1
    else
        return r, 1
    end
end

-- 角度转向
function math.angle_to(from, to, restrict)
    if math.math_angle(to, from) <= restrict then
        from = to
    else
        if math.math_angle(to, from + restrict) <
            math.math_angle(to, from - restrict) then
            from = from + restrict
        else
            from = from - restrict
        end
    end
    return from
end

-- 将value限定在[min,max]区间
function math.clamp(_value, min, max) return
    math.max(math.min(_value, max), min) end

-- 以x为插值在from到to间平滑过渡
function math.smmothstep(from, to, x)
    -- 当x取值为leftX时，t=0
    -- 当x取值为rightX时，t=1
    local leftX, rightX = 0, 1
    local t = math.clamp((x - leftX) / (rightX - leftX), 0, 1)
    local progress = t * t * (3 - 2 * t)
    return from + (to - from) * progress
end

-- 求两个整数的最大公约数（欧几里得算法）
function math.gcd(int1, int2)
    if int2 == 0 then
        return int1
    else
        return math.gcd(int2, int1 % int2)
    end
end

-- 求两个整数的最大公约数以及通解（扩展欧几里得算法）
function math.gcd_ex(int1, int2)
    if int2 == 0 then return 1, 0, int1 end
    local x, y, q = math.gcd_ex(int2, int1 % int2)
    local temp = x
    x = y
    y = temp - int1 // int2 * y
    return x, y, q
end

return math
