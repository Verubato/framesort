local _, addon = ...
local logLevelDebug = "Debug"
local logLevelWarning = "Warning"
local logLevelError = "Error"
local printOutput = false
local entries = {}
local M = {}
addon.Log = M

local function Write(msg, level)
    if printOutput then
        print(string.format("FrameSort: %s - %s", level, msg))
    end

    if not addon.Options.Logging or not addon.Options.Logging.Enabled then return end

    entries[#entries + 1] = {
        Message = msg,
        Level = level,
        Timestamp = date("%Y-%m-%d %H:%M:%S")
    }
end

function addon:InitLogging()
    -- reset the log on each run
    FrameSortDB.Log = entries
end

---Logs a debug message.
---@param msg string
function M:Debug(msg)
    Write(msg, logLevelDebug)
end

---Logs a warning message.
---@param msg string
function M:Warning(msg)
    Write(msg, logLevelWarning)
end

---Logs an error message.
---@param msg string
function M:Error(msg)
    Write(msg, logLevelError)
end
