local log = require 'jass.log'

local function split(str, p)
    local rt = {}
    str:gsub('[^' .. p .. ']+', function(w) table.insert(rt, w) end)
    return rt
end

string.split = split


log.path = game.Name .. '\\日志\\' .. split(log.path, '\\')[2]
log.debug '日志系统装载完毕,向着星辰大海出击!'

local std_print = print
function print(...)
    log.info(...)
    return std_print(...)
end

local log_error = log.error
function log.error(...)
    local trc = debug.traceback()
    log_error(...)
    log_error(trc)
    std_print(...)
    std_print(trc)
end

return log
