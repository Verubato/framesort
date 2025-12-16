---@type string, Addon
local addonName, addon = ...
local wow = addon.WoW.Api
local events = addon.WoW.Events
---@class Log
local M = {
    Level = {
        Debug = 1,
        Notify = 2,
        Warning = 3,
        Error = 4,
        Critical = 5,
        Bug = 6,
    },
}
addon.Logging.Log = M

local started = wow.GetTimePreciseSec()
local cache = {}
local enableCache = true
local maxCacheSize = 100
local warned = {}
local callbacks = {}

local function NotifyCallbacks(msg, level, timestamp)
    for _, callback in ipairs(callbacks) do
        callback(msg, level, timestamp)
    end
end

local function Write(msg, level)
    NotifyCallbacks(msg, level, wow.GetTimePreciseSec() - started)

    if enableCache then
        if #cache >= maxCacheSize then
            table.remove(cache, 1)
        end

        cache[#cache + 1] = {
            Message = msg,
            Level = level,
            Timestamp = wow.GetTimePreciseSec() - started,
        }
    end

    if level == M.Level.Notify then
        print(string.format("FrameSort - %s", msg))
    elseif level == M.Level.Critical or level == M.Level.Bug then
        print(string.format("|cFFFF0000FrameSort - %s|r", msg))
    end
end

local function OnAddonError(_, eventName, errorAddon, error)
    if errorAddon ~= addonName then
        return
    end

    if not error then
        return
    end

    Write(error, M.Level.Error)
end

---Returns a text representation of the log level.
function M:LevelText(level)
    if level == M.Level.Debug then
        return "Debug"
    elseif level == M.Level.Notify then
        return "Notify"
    elseif level == M.Level.Warning then
        return "Warning"
    elseif level == M.Level.Error then
        return "Error"
    elseif level == M.Level.Critical then
        return "Critical"
    elseif level == M.Level.Bug then
        return "Bug"
    end

    return "Unknown"
end

---Logs a debug message.
---@param msg string
function M:Debug(msg, ...)
    local formatted = string.format(msg, ...)
    Write(formatted, M.Level.Debug)
end

---Logs and prints a notification message.
---@param msg string
function M:Notify(msg, ...)
    local formatted = string.format(msg, ...)
    Write(formatted, M.Level.Notify)
end

---Logs a warning message.
---@param msg string
function M:Warning(msg, ...)
    local formatted = string.format(msg, ...)
    Write(formatted, M.Level.Warning)
end

---Logs a warning message if one hasn't already been logged with the same message.
---@param msg string
function M:WarnOnce(msg, ...)
    local formatted = string.format(msg, ...)

    if warned[formatted] then
        return
    end

    warned[formatted] = true

    Write(formatted, M.Level.Warning)
end

---Logs an error message.
---@param msg string
function M:Error(msg, ...)
    local formatted = string.format(msg, ...)
    Write(formatted, M.Level.Error)
end

---Logs and prints a critical error message.
---@param msg string
function M:Critical(msg, ...)
    local formatted = string.format(msg, ...)
    Write(formatted, M.Level.Critical)
end

---Logs and prints a critical error bug message.
---@param msg string
function M:Bug(msg, ...)
    local formatted = string.format(msg, ...) .. " Please notify the developer about this."
    Write(formatted, M.Level.Bug)
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
    frame:RegisterEvent(events.ADDON_ACTION_BLOCKED)
    frame:RegisterEvent(events.ADDON_ACTION_FORBIDDEN)
end
