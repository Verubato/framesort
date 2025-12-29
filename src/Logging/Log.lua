---@type string, Addon
local addonName, addon = ...
local wow = addon.WoW.Api
local events = addon.WoW.Events
local L = addon.Locale
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
local warningsNotified = {}
local errorsNotified = {}
local bugsNotified = {}
local callbacks = {}

local function NotifyCallbacks(msg, level, timestamp)
    for _, callback in ipairs(callbacks) do
        callback(msg, level, timestamp)
    end
end

local function LogPush(db, entry)
    db.Buffer = db.Buffer or {}
    db.Max = db.Max or addon.Configuration.DbDefaults.Log.Max
    db.Head = db.Head or 1
    db.Size = db.Size or 0

    local buf = db.Buffer
    local max = db.Max

    buf[db.Head] = entry
    db.Head = db.Head % max + 1
    db.Size = math.min(db.Size + 1, max)
end

local function Write(msg, level)
    NotifyCallbacks(msg, level, wow.GetTimePreciseSec() - started)

    -- addon.DB may not have been inititalised yet, so use the global
    if FrameSortDB then
        FrameSortDB.Log = FrameSortDB.Log or wow.CopyTable(addon.Configuration.DbDefaults.Log)

        local entry = {
            Message = msg,
            Level = level,
            Timestamp = wow.GetTimePreciseSec() - started,
        }

        LogPush(FrameSortDB.Log, entry)
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

---Iterates over the database log entries and invokes the callback for each log entry.
---@param fn function()
function M:IterateLog(fn)
    if not FrameSortDB then
        return
    end

    if not FrameSortDB.Log then
        return
    end

    local db = FrameSortDB.Log
    local buffer = db.Buffer
    local count = db.Size
    local head = db.Head
    local max = db.Max

    if not buffer or not count or not head or not max then
        return
    end

    if count == 0 then
        return
    end

    -- Oldest entry is count steps behind the current head
    local firstIndex = head - count

    if firstIndex <= 0 then
        firstIndex = firstIndex + max
    end

    for offset = 0, count - 1 do
        local index = firstIndex + offset
        if index > max then
            index = index - max
        end

        fn(buffer[index])
    end
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

---Logs and prints the combat lockdown notification message.
function M:NotifyCombatLockdown()
    self:Notify(L["Can't do that during combat."])
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

    if warningsNotified[formatted] then
        return
    end

    warningsNotified[formatted] = true

    Write(formatted, M.Level.Warning)
end

---Logs an error message if one hasn't already been logged with the same message.
---@param msg string
function M:ErrorOnce(msg, ...)
    local formatted = string.format(msg, ...)

    if errorsNotified[formatted] then
        return
    end

    errorsNotified[formatted] = true

    Write(formatted, M.Level.Error)
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

    if bugsNotified[formatted] then
        return
    end

    bugsNotified[formatted] = true

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

function M:Init()
    local frame = wow.CreateFrame("Frame")
    frame:SetScript("OnEvent", OnAddonError)
    frame:RegisterEvent(events.ADDON_ACTION_BLOCKED)
    frame:RegisterEvent(events.ADDON_ACTION_FORBIDDEN)
end
