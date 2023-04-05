local jass = require "jass.common"
local japi = require "jass.japi"
local slk = require "jass.slk"
local message = require "jass.message"
local console = require "jass.console"

local std_print = print
function print(...) std_print(('[%.3f]'):format(os.clock()), ...) end

-- 使用框架的基础代码(这行代码本来是放在Gameplay.GameplayEntry的)
require "Gameframework.GameframeworkEntry"

-- 后续使用全局变量Yuyuko,Types和Events完成游戏逻辑即可
