---@type string, Addon
local _, addon = ...
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local fsLuaEx = addon.Language.LuaEx
local fsLog = addon.Logging.Log
local fsScheduler = addon.Scheduling.Scheduler
local wow = addon.WoW.Api
local events = addon.WoW.Events
local capabilities = addon.WoW.Capabilities
local M = {}
local sortCallbacks = {}
local eventFrame = nil

fsProviders.sArena = M
table.insert(fsProviders.All, M)

local function RequestSort(reason)
    for _, callback in ipairs(sortCallbacks) do
        callback(M, reason)
    end
end

local function OnEvent(_, event)
    RequestSort(event)
end

local function Init()
    if not M:Enabled() then
        return
    end

    eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent(events.ARENA_OPPONENT_UPDATE)

    if capabilities.HasEnemySpecSupport() then
        eventFrame:RegisterEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
    end
end

function M:Name()
    return "sArena"
end

function M:Enabled()
    -- there are a few of variants of sArena
    -- e.g. "sArena Updated" and "sArena_Updated2_by_sammers"
    -- so instead of checking for enabled state just check if the container exists
    return type(sArena) == "table"
end

function M:Init()
    -- note we can't yet check if sarena is enabled here because sArena may not have been loaded yet
    -- so delay the initalisation for later
    fsScheduler:RunWhenEnteringWorldOnce(Init)
end

function M:RegisterRequestSortCallback(callback)
    if not callback then
        fsLog:Bug("sArena:RegisterRequestSortCallback() - callback must not be nil.")
        return
    end

    sortCallbacks[#sortCallbacks + 1] = callback
end

function M:RegisterContainersChangedCallback() end

function M:Containers()
    if not M:Enabled() then
        return {}
    end

    ---@type FrameContainer
    local arena = {
        Frame = sArena,
        Type = fsFrame.ContainerType.EnemyArena,
        LayoutType = fsFrame.LayoutType.Hard,
        AnchorPoint = "CENTER",
        Spacing = function()
            local layout = fsLuaEx:SafeGet(sArena, { "db", "profile", "currentLayout" }) or "BlizzArena"
            local vertical = fsLuaEx:SafeGet(sArena, { "db", "profile", "layoutSettings", layout, "spacing" }) or 20

            return {
                Horizontal = 0,
                Vertical = vertical,
            }
        end,
    }

    return {
        arena,
    }
end
