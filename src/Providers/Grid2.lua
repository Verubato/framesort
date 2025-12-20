---@type string, Addon
local _, addon = ...
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local fsLuaEx = addon.Language.LuaEx
local fsLog = addon.Logging.Log
local fsScheduler = addon.Scheduling.Scheduler
local wow = addon.WoW.Api
local wowEx = addon.WoW.WowEx
local events = addon.WoW.Events
local M = {}
local eventFrame = nil
local sortCallbacks = {}

fsProviders.Grid2 = M
table.insert(fsProviders.All, M)

local function RequestSort(reason)
    for _, callback in ipairs(sortCallbacks) do
        callback(M, reason)
    end
end

local function OnEvent(_, event)
    RequestSort(event)
end

local function EventsFallback()
    eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent(events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(events.PLAYER_ROLES_ASSIGNED)
    eventFrame:RegisterEvent(events.PLAYER_SPECIALIZATION_CHANGED)
    eventFrame:RegisterEvent(events.UNIT_PET)
end

function M:Name()
    return "Grid2"
end

function M:Enabled()
    return wowEx.IsAddOnEnabled("Grid2")
end

function M:Init()
    if not M:Enabled() then
        return
    end

    local canHook = true

    if not Grid2Layout then
        fsLog:Bug("Grid2Layout is nil.")
        canHook = false
    end

    if Grid2Layout and not Grid2Layout.LoadLayout then
        fsLog:Bug("Grid2Layout:LoadLayout is nil.")
        canHook = false
    end

    if canHook then
        wow.hooksecurefunc(Grid2Layout, "LoadLayout", function()
            if Grid2LayoutHeader1 then
                Grid2LayoutHeader1:HookScript("OnEvent", OnEvent)
            else
                fsLog:Bug("Grid2LayoutHeader1 is nil.")
            end
        end)
    else
        EventsFallback()
    end
end

function M:RegisterRequestSortCallback(callback)
    if not callback then
        fsLog:Bug("Grid2:RegisterRequestSortCallback() - callback must not be nil.")
        return
    end

    sortCallbacks[#sortCallbacks + 1] = callback
end

function M:RegisterContainersChangedCallback() end

function M:Containers()
    local containers = {}

    if not M:Enabled() then
        return containers
    end

    if Grid2LayoutHeader1 then
        ---@type FrameContainer
        local party = {
            Frame = Grid2LayoutHeader1,
            Type = fsFrame.ContainerType.Party,
            LayoutType = fsFrame.LayoutType.NameList,
            ShowUnit = function(_, unitId)
                if not wow.IsInInstance() then
                    return true
                end

                local selectedLayout = fsLuaEx:SafeGet(Grid2, { "db", "profile", "raidSizeType" })
                local onlyShowUnitsInRaid = 3

                if selectedLayout ~= onlyShowUnitsInRaid then
                    return true
                end

                if not wow.C_Map or not wow.C_Map.GetBestMapForUnit then
                    return true
                end

                local instanceId = wow.C_Map.GetBestMapForUnit("player")
                local unitInstanceId = wow.C_Map.GetBestMapForUnit(unitId)

                return instanceId == unitInstanceId
            end,
        }

        containers[#containers + 1] = party
    end

    return containers
end
