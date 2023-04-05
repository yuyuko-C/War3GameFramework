local message = require "jass.message"

local mt = {}
mt.HOLD_FRAME = 200

local keyDownCallbacks = {}
local keyUpCallbacks = {}
local keyClickCallbacks = {}
local keyHoldCallbacks = {}
local keyReleaseCallbacks = {}

function mt.AddKeyDownListener(callback)
    local index = Yuyuko.LinqList.Index(keyDownCallbacks,
        function(x) return x == callback end)
    if not index then table.insert(keyDownCallbacks, callback) end
end

function mt.AddKeyUpListener(callback)
    local index = Yuyuko.LinqList.Index(keyUpCallbacks,
        function(x) return x == callback end)
    if not index then table.insert(keyUpCallbacks, callback) end
end

function mt.AddKeyClickListener(callback)
    local index = Yuyuko.LinqList.Index(keyClickCallbacks,
        function(x) return x == callback end)
    if not index then table.insert(keyClickCallbacks, callback) end
end

function mt.AddKeyReleaseListener(callback)
    local index = Yuyuko.LinqList.Index(keyReleaseCallbacks,
        function(x) return x == callback end)
    if not index then table.insert(keyReleaseCallbacks, callback) end
end

function mt.RemoveKeyDownListener(callback)
    local index = Yuyuko.LinqList.Index(keyDownCallbacks,
        function(x) return x == callback end)
    if index then table.remove(keyDownCallbacks, index) end
end

function mt.RemoveKeyUpListener(callback)
    local index = Yuyuko.LinqList.Index(keyUpCallbacks,
        function(x) return x == callback end)
    if index then table.remove(keyUpCallbacks, index) end
end

function mt.RemoveKeyClickListener(callback)
    local index = Yuyuko.LinqList.Index(keyClickCallbacks,
        function(x) return x == callback end)
    if index then table.remove(keyClickCallbacks, index) end
end

function mt.RemoveKeyReleaseListener(callback)
    local index = Yuyuko.LinqList.Index(keyReleaseCallbacks,
        function(x) return x == callback end)
    if index then table.remove(keyReleaseCallbacks, index) end
end

-- 注册本地键盘事件
local function RegistLocalKeyEvent()
    local key_record = {}
    local key_cast = {}

    -- 本地键盘事件（全都是本地事件）
    function message.hook(msg)
        -- 改键软件依然生效
        if not ((msg.type == 'key_down') or (msg.type == 'key_up')) then
            -- //TODO：解决这个
            -- print('other operation')
            return true
        end
        -- print(msg.code) --debug用

        -- 将按键转化为文本
        local msgCode = msg.code
        if (msg.type == 'key_down') then
            -- print('本地玩家按下按键' .. mt.Code2Text[msgCode])
            key_record[msgCode] = Yuyuko.TimeLine:Clock()
            Yuyuko.LinqList.Foreach(keyDownCallbacks,
                function(x) x(msgCode); end)
        end
        if (msg.type == 'key_up') then
            -- print('本地玩家抬起按键' .. mt.Code2Text[msgCode])
            local keydown_clock = key_record[msgCode] or Yuyuko.TimeLine:Clock()
            if Yuyuko.TimeLine:Clock() - keydown_clock <= mt.HOLD_FRAME then
                print('本地玩家点击按键' .. mt.Code2Text[msgCode])
                Yuyuko.LinqList.Foreach(keyClickCallbacks,
                    function(x) x(msgCode); end)
            else
                print('本地玩家释放按键' .. mt.Code2Text[msgCode])
                Yuyuko.LinqList.Foreach(keyReleaseCallbacks,
                    function(x) x(msgCode); end)
            end
            key_record[msgCode] = nil
            key_cast[msgCode] = nil
            Yuyuko.LinqList.Foreach(keyUpCallbacks, function(x)
                x(msgCode);
            end)
        end

        return true
    end

    -- 本地拓展键盘事件
    local function HoldEventFunc(keyCode)
        local keydown_clock = key_record[keyCode] or Yuyuko.TimeLine:Clock()
        if Yuyuko.TimeLine:Clock() - keydown_clock > mt.HOLD_FRAME then
            -- //TODO：解决这个
            print('本地玩家长按按键' .. mt.Code2Text[keyCode])
            Yuyuko.LinqList.Foreach(keyHoldCallbacks,
                function(x) x(keyCode); end)
            key_cast[keyCode] = true
        end
    end

    Yuyuko.TimeLine:Loop(game.FRAME * 1000, function()
        for keyCode, value in pairs(key_record) do
            if not key_cast[keyCode] then HoldEventFunc(keyCode) end
        end
    end)
end

function mt.init()
    -- keycode与文本的对应表
    mt.Code2Text = {}
    mt.Text2Code = {}
    for key, value in pairs(message.keyboard) do
        mt.Text2Code[key] = value
        mt.Code2Text[value] = key
    end

    -- 注册本地键盘事件
    RegistLocalKeyEvent()
end

return mt
