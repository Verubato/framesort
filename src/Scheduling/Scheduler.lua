---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local events = addon.WoW.Api.Events
---@class Scheduler: IInitialise
local M = {}
addon.Scheduling.Scheduler = M

local combatEndCallbacks = {}
local combatEndKeyedCallbacks = {}

local function OnCombatEnded()
    for _, callback in ipairs(combatEndCallbacks) do
        callback()
    end

    for _, callback in pairs(combatEndKeyedCallbacks) do
        callback()
    end

    combatEndCallbacks = wow.wipe(combatEndCallbacks)
    combatEndKeyedCallbacks = wow.wipe(combatEndKeyedCallbacks)
end

---Invokes the callback on the next frame.
---@param callback fun()
function M:RunNextFrame(callback)
    wow.C_Timer.After(0, callback)
end

---Invokes the callback once combat ends.
---@param key string? an optional key which will ensure only the latest callback provided with the same key will be executed.
---@param callback fun()
function M:RunWhenCombatEnds(callback, key)
    if not wow.InCombatLockdown() then
        callback()
        return
    end

    if key then
        combatEndKeyedCallbacks[key] = callback
    else
        combatEndCallbacks[#combatEndCallbacks + 1] = callback
    end
end

function M:Init()
    if #combatEndCallbacks > 0 then
        combatEndCallbacks = {}
    end

    if #combatEndKeyedCallbacks > 0 then
        combatEndKeyedCallbacks = {}
    end

    local eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnCombatEnded)
    eventFrame:RegisterEvent(events.PLAYER_REGEN_ENABLED)
end
