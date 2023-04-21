local _, addon = ...
local logLevelDebug = "Debug"
local logLevelWarning = "Warning"
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

---Prints a debug message to the chat window if DebugMode is enabled.
---@param msg string
function addon:Debug(msg)
    Write(msg, logLevelDebug)
end

---Prints a warning message to the chat window if DebugMode is enabled.
---@param msg string
function addon:Warning(msg)
    Write(msg, logLevelWarning)
end
