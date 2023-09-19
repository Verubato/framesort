---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsSorting = addon.Modules.Sorting
local fsProviders = addon.Providers
local M = {}
addon.Modules.Sorting.Taintless = M

local frameRefreshEvents = {
    wow.Events.UNIT_PET,
    wow.Events.GROUP_ROSTER_UPDATE,
}

local function BlockFrameUpdates(container)
    for _, event in ipairs(frameRefreshEvents) do
        container:UnregisterEvent(event)
    end
end

local function EnableFrameUpdates(container)
    for _, event in ipairs(frameRefreshEvents) do
        container:RegisterEvent(event)
    end
end

local function OnCombatEnded()
    local containers = {
        fsProviders.Blizzard:PartyContainer(),
        fsProviders.Blizzard:RaidContainer(),
        fsProviders.Blizzard:EnemyArenaContainer(),
    }

    for _, container in ipairs(containers) do
        if container then
            EnableFrameUpdates(container)
        end
    end
end

local function OnCombatStarting()
    local containers = {
        fsProviders.Blizzard:PartyContainer(),
        fsProviders.Blizzard:RaidContainer(),
        fsProviders.Blizzard:EnemyArenaContainer(),
    }

    for _, container in ipairs(containers) do
        if container then
            BlockFrameUpdates(container)
        end
    end
end

local function OnEvent(_, event)
    if event == wow.Events.PLAYER_REGEN_ENABLED then
        OnCombatEnded()
    elseif event == wow.Events.PLAYER_REGEN_DISABLED then
        OnCombatStarting()
    end
end

---Attempts to sort frames.
---@return boolean sorted true if sorted, otherwise false.
---@param provider FrameProvider the provider to sort.
function M:TrySort(provider)
    return fsSorting.Core:TrySort(provider)
end

function M:Init()
    local eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent(wow.Events.PLAYER_REGEN_ENABLED)
    eventFrame:RegisterEvent(wow.Events.PLAYER_REGEN_DISABLED)
end
