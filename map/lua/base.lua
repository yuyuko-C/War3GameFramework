local runtime = require 'jass.runtime'
local console = require 'jass.console'

game = {}

-- 判断是否是发布版本
game.release = not pcall(require, 'lua.currentpath')

-- 测试版本和发布版本的脚本路径
if game.release then
    package.path = package.path .. [[;Poi\]] .. game.version ..
        [[\?.lua;scripts\?.lua;]]
end


-- 版本号
game.version = '1.0'

-- 游戏名称
game.Name = "我的游戏"

-- 帧速
game.FRAME = 0.03

-- 补偿帧数
game.Delta = 10

-- 游戏帧间隔
game.DeltaTime = game.FRAME * game.Delta * 100

-- 打开控制台
if not game.release then
    -- 调试器端口
    runtime.debugger = 4279
    -- 打开控制台
    console.enable = true
end

-- 重载print,自动转换编码
print = console.write

-- 将句柄等级设置为0(地图中所有的句柄均使用table封装)
runtime.handle_level = 0

-- 关闭等待
runtime.sleep = false

function game.error_handle(msg)
    print("---------------------------------------")
    print(tostring(msg) .. "\n")
    print(debug.traceback())
    print("---------------------------------------")
end

-- 错误汇报
function runtime.error_handle(msg) game.error_handle(msg) end

-- 初始化本地脚本
local function init() require 'main' end

xpcall(init, function(msg) print(msg, '\n', debug.traceback()) end)
