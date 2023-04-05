local bignum = require "jass.bignum"

local mt = {}


local suc, config = pcall(require, '(RSAConfig)')
if not suc then
    return mt
end

if config.e then mt.e_bn = bignum.new(bignum.bin(config.e)) end
if config.n then mt.n_bn = bignum.new(bignum.bin(config.n)) end
if config.d then mt.d_bn = bignum.new(bignum.bin(config.d)) end


-- 加密信息
-- @param 数字或字符串
function mt.encrypt(c)
    local c_bn = bignum.new(c)
    local m_bn = c_bn:powmod(mt.e_bn, mt.n_bn)
    return tostring(m_bn)
end

-- 解密信息
-- @加密后的结果
function mt.decrypt(m)
    local m_bn = bignum.new(m)
    local c_bn = m_bn:powmod(mt.d_bn, mt.n_bn)
    return tostring(c_bn)
end

local sha1 = bignum.sha1

-- 生成签名
--	文本
function mt.get_sign(content) return mt.decrypt(sha1(content)) end

-- 验证签名
--	文本
--	签名
function mt.check_sign(content, sign)
    return
        sha1(content) == mt.encrypt(sign)
end

return mt
