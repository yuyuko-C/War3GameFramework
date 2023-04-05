local console = require "jass.console"
local jass = require "jass.common"
local runtime = require "jass.runtime"

local mt = {}
mt.__index = mt

local InputStr = nil
local IsOpen = false

local function OnSyncSuccess(data)
    for key, value in pairs(data) do print(key, value) end

    -- jass.DisplayTimedTextToPlayer(jass.Player(0), 0, 0, 60,
    -- '你在控制台中输入了:' .. data.)
end

local function DealMsgAction(action)
    if InputStr == nil then return end
    if not IsOpen then
        InputStr = nil
        return
    end

    local index = string.find(InputStr, '@')
    if not index then
        print("不是命令不予处理,命令格式:@xxxx")
        InputStr = nil
        return
    end

    local info = string.sub(InputStr, 2, string.len(InputStr))
    -- 处理命令字符串
    local command = "Item"
    local value = "SetItem1"
    print("同步")
    Types.Player.GetLocalPlayer():SyncText({ [command] = value }, OnSyncSuccess)
    -- 处理结束后清空字符串
    InputStr = nil
end

function mt:OpenConsole()
    print("调试器开启")
    console.enable = true
end

function mt:CloseConsole()
    print("调试器关闭")
    console.enable = false
end

function mt.init()
    -- 调试器端口
    runtime.debugger = 4279

    -- 获取输入
    Yuyuko.TimeLine:Loop(game.FRAME * 1000, function(action)
        -- 传入的匿名函数要等到下一次进入才能处理
        console.read(function(str)
            local length = string.len(str)
            if length <= 2 then return end
            -- 去除\r\n
            str = string.sub(str, 1, length - 2)
            InputStr = str
        end)
    end);
    -- 处理输入
    Yuyuko.TimeLine:Loop(game.FRAME * 1000, DealMsgAction)
end

return mt
