local _, addon = ...
local logLevelDebug = "Debug"
local logLevelWarning = "Warning"
local logLevelError = "Error"
local log = {}

local function Write(msg, level)
    if not addon.Options.Logging or not addon.Options.Logging.Enabled then return end

    log[#log + 1] = {
        Message = msg,
        Level = level,
        Timestamp = date("%Y-%m-%d %H:%M:%S")
    }
end

function addon:InitLogging()
    -- reset the log on each run
    FrameSortDB.Log = log
end

---Logs a debug message.
---@param msg string
function addon:Debug(msg)
    Write(msg, logLevelDebug)
end

---Logs a warning message.
---@param msg string
function addon:Warning(msg)
    Write(msg, logLevelWarning)
end

---Logs an error message.
---@param msg string
function addon:Error(msg)
    Write(msg, logLevelError)
end
