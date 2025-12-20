---@type string, Addon
local _, addon = ...
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local fsLog = addon.Logging.Log
local wow = addon.WoW.Api
local events = addon.WoW.Events
local M = {}
local containersChangedCallbacks = {}
local sortCallbacks = {}
local eventFrame = nil

fsProviders.Suf = M
table.insert(fsProviders.All, M)

local function RequestSort(reason)
    for _, callback in ipairs(sortCallbacks) do
        callback(M, reason)
    end
end

local function OnEvent(_, event)
    RequestSort(event)
end

function M:Name()
    return "Shadowed Unit Frames"
end

function M:Enabled()
    return wow.GetAddOnEnableState("ShadowedUnitFrames") ~= 0
end

function M:Init()
    if not M:Enabled() then
        return
    end

    eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent(events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(events.PLAYER_ROLES_ASSIGNED)
    eventFrame:RegisterEvent(events.PLAYER_SPECIALIZATION_CHANGED)
    eventFrame:RegisterEvent(events.UNIT_PET)
end

function M:RegisterRequestSortCallback(callback)
    if not callback then
        fsLog:Bug("SUF:RegisterRequestSortCallback() - callback must not be nil.")
        return
    end

    sortCallbacks[#sortCallbacks + 1] = callback
end

function M:RegisterContainersChangedCallback() end

function M:Containers()
    local containers = {}

    if not M:Enabled() then
        return
    end

    if SUFHeaderparty then
        ---@type FrameContainer
        local party = {
            Frame = SUFHeaderparty,
            Type = fsFrame.ContainerType.Party,
            LayoutType = fsFrame.LayoutType.NameList,
        }

        containers[#containers + 1] = party
    end

    if SUFHeaderarena then
        ---@type FrameContainer
        local arena = {
            Frame = SUFHeaderarena,
            Type = fsFrame.ContainerType.EnemyArena,
            LayoutType = fsFrame.LayoutType.NameList,
        }

        containers[#containers + 1] = arena
    end

    return containers
end
