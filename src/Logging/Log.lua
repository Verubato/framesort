---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local logLevelDebug = "Debug"
local logLevelWarning = "Warning"
local logLevelError = "Error"
---@class Log
local M = {}
addon.Logging.Log = M

local started = wow.GetTimePreciseSec()
local cache = {}
local enableCache = true
local callbacks = {}

local function NotifyCallbacks(msg, level, timestamp)
    for _, callback in ipairs(callbacks) do
        callback(msg, level, timestamp)
    end
end

local function Write(msg, level)
    NotifyCallbacks(msg, level, wow.GetTimePreciseSec() - started)

    if enableCache then
        cache[#cache + 1] = {
            Message = msg,
            Level = level,
            Timestamp = wow.GetTimePreciseSec() - started
        }
    end

    local enabled = addon.DB and addon.DB.Options and addon.DB.Options.Logging and addon.DB.Options.Logging.Enabled
    if not enabled then
        return
    end

    print(string.format("FrameSort: %s - %s", level, msg))
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

---Adds a callback to be invoked whenever a log entry is added.
---@param callback function
function M:AddLogCallback(callback)
    callbacks[#callbacks + 1] = callback
end

---Removes all cached log entries and prevents futher caching.
function M:ClearAndDisableCache()
    cache = {}
    enableCache = false
end

---Returns a collection of { Message, Level, Timestamp } cached log entries.
function M:GetCachedEntries()
    return cache
end
