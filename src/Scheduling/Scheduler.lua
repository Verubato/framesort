---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsEnumerable = addon.Collections.Enumerable
local events = addon.WoW.Api.Events
---@class Scheduler: Initialise
local M = {}
addon.Scheduling.Scheduler = M

local combatEndCallbacks = {}

local function OnCombatEnded()
    local copy = fsEnumerable:From(combatEndCallbacks):ToTable()
    wow.wipe(combatEndCallbacks)

    for _, callback in ipairs(copy) do
        callback()
    end
end

---Invokes the callback on the next frame.
---@param callback fun()
function M:RunNextFrame(callback)
    wow.C_Timer.After(0, callback)
end

---Invokes the callback once combat ends.
---@param callback fun()
function M:RunWhenCombatEnds(callback)
    if not wow.InCombatLockdown() then
        callback()
        return
    end

    combatEndCallbacks[#combatEndCallbacks + 1] = callback
end

function M:Init()
    if #combatEndCallbacks > 0 then
        combatEndCallbacks = {}
    end

    local eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnCombatEnded)
    eventFrame:RegisterEvent(events.PLAYER_REGEN_ENABLED)
end
