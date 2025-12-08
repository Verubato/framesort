---@type string, Addon
local addonName, addon = ...
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
            Timestamp = wow.GetTimePreciseSec() - started,
        }
    end
end

local function OnAddonError(_, eventName, errorAddon, error)
    if errorAddon ~= addonName then
        return
    end

    Write(error, "Error")
end

---Logs a debug message.
---@param msg string
function M:Debug(msg, ...)
    local formatted = string.format(msg, ...)
    Write(formatted, logLevelDebug)
end

---Logs a warning message.
---@param msg string
function M:Warning(msg, ...)
    local formatted = string.format(msg, ...)
    Write(formatted, logLevelWarning)
end

---Logs an error message.
---@param msg string
function M:Error(msg, ...)
    local formatted = string.format(msg, ...)
    Write(formatted, logLevelError)
end

---Logs a message.
---@param msg string
function M:Log(msg, level, ...)
    local formatted = string.format(msg, ...)
    Write(formatted, level)
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

function M:Init()
    local frame = wow.CreateFrame("Frame")
    frame:HookScript("OnEvent", OnAddonError)
    frame:RegisterEvent(wow.Events.ADDON_ACTION_BLOCKED)
    frame:RegisterEvent(wow.Events.ADDON_ACTION_FORBIDDEN)
end
