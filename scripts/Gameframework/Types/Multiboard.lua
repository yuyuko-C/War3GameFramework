local jass = require 'jass.common'


local mt = {}
mt.__index = mt
mt.Type = "Multiboard"
mt._Handle = 0
mt._RowsCount = 0
mt._ColumnsCount = 0


-- 修改行数
function mt:SetRowsCount(count)
    jass.MultiboardSetRowCount(self._Handle, count)
    self._RowsCount = count
end

-- 修改列数
function mt:SetColumnsCount(count)
    jass.MultiboardSetColumnCount(self._Handle, count)
    self._ColumnsCount = count
end

-- 修改标题文字
function mt:SetTitle(title)
    jass.MultiboardSetTitleText(self._Handle, title)
end

-- 显示多面板
function mt:Show() jass.MultiboardDisplay(self._Handle, true) end

-- 隐藏多面板
function mt:Hide() jass.MultiboardDisplay(self._Handle, false) end

-- 最小化多面板
function mt:Minimize(flag)
    jass.MultiboardMinimize(self._Handle, flag)
end

-- 获得项目
function mt:GetItem(column, row)
    local t = self[column]
    if t then
        return t[row]
    end
    return 0
end

-- 设置项目图标
function mt:SetItemIcon(column, row, src)
    jass.MultiboardSetItemIcon(self:GetItem(column, row), src)
end

-- 设置某个Item的文字
function mt:SetItemText(column, row, txt)
    jass.MultiboardSetItemValue(self:GetItem(column, row), txt)
end

-- 设置某个Item的图标和文字是否显示
function mt:SetItemStyle(column, row, show_txt, show_icon)
    jass.MultiboardSetItemStyle(self:GetItem(column, row), show_txt, show_icon)
end

-- 设置某个Item的宽度
function mt:SetItemWidth(column, row, w)
    jass.MultiboardSetItemWidth(self:GetItem(column, row), w)
end

-- 设置所有item的style
function mt:SetBoardStyle(show_txt, show_icon)
    jass.MultiboardSetItemsStyle(self._Handle, show_txt, show_icon)
end

-- 设置Item的宽度
function mt:SetBoardWidth(w)
    jass.MultiboardSetItemsWidth(self._Handle, w)
    self:Hide()
    self:Show()
end

function mt:Destroy()
    jass.DestroyMultiboard(self._Handle)
end

function mt:Clear()
    jass.MultiboardClear(self._Handle)
    self._Handle = 0
    self._RowsCount = 0
    self._ColumnsCount = 0
    Yuyuko.LinqList.Clear(mt)
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



-- 创建一个多面板
function mt.Create(column, row)
    local board = PoolGet()
    board._Handle = jass.CreateMultiboard()
    board:SetColumnsCount(column or 0)
    board:SetRowsCount(row or 0)
    board:Show()

    -- 保存多面板项目
    for column = 1, column do
        board[column] = {}
        for row = 1, row do
            board[column][row] = jass.MultiboardGetItem(board._Handle, row - 1,
                column - 1)
        end
    end
    return board
end

return mt
