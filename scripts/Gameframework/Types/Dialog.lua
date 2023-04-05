local jass = require 'jass.common'


local mt = {}
mt.__index = mt
mt.Type = "Dialog"
mt._Handle = 0
mt._ButtonsTrigger = {}


local allInstance = { mt }
table.remove(allInstance)


function mt:SetTitle(title)
    jass.DialogSetMessage(self._Handle, title)
end

function mt:AddButton(text, hotkey, action)
    hotkey = hotkey and Yuyuko.LocalInput.Text2Code[hotkey] or nil
    local button = jass.DialogAddButton(self._Handle, text, hotkey)
    if action ~= nil then
        local trig = Yuyuko.CreateTrigger(action)
        jass.TriggerRegisterDialogButtonEvent(trig, button)
        self._ButtonsTrigger[button] = trig
    end
end

function mt:AddQuitGameButton()
    jass.DialogAddQuitButton(self._Handle, true, "离开游戏", "N")
end

function mt:ShowToPlayer(player, flag)
    jass.DialogDisplay(player._Handle, self._Handle, flag)
end

function mt:Destroy()
    self:Clear()
    jass.DialogDestroy(self._Handle)
end

function mt:Clear()
    print("clear")
    jass.DialogClear(self._Handle)
    allInstance[self._Handle] = nil
    for key, value in pairs(self._ButtonsTrigger) do
        Yuyuko.DestroyTrigger(value)
        self._ButtonsTrigger[key] = nil
    end
end

local Collection = {}
local function PoolGet()
    local count = #Collection
    if count > 0 then
        return table.remove(Collection)
    else
        local t = setmetatable({}, mt)
        t._Handle = jass.DialogCreate()
        return t
    end
end
Yuyuko.RefrencePool[mt.Type] = Collection


function mt.GetByHandle(handle)
    return allInstance[handle]
end

-- 创建一个对话框
function mt.Create()
    local dialog = PoolGet()
    return dialog
end

return mt
