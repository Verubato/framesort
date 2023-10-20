---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsEnumerable = addon.Collections.Enumerable
local fsProviders = addon.Providers
local fsScheduler = addon.Scheduling.Scheduler
local events = addon.WoW.Api.Events
---@class BlizzardFrameProvider: FrameProvider
local M = {}
local eventFrame = nil
local sortCallbacks = {}
local containersChangedCallbacks = {}
local cvarsToUpdateContainer = {
    "HorizontalGroups",
    "KeepGroupsTogether",
}
local cvarsPatternsToRunSort = {
    "raidOptionDisplay.*",
    "pvpOptionDisplay.*",
    "raidFrames.*",
    "pvpFrames.*"
}

fsProviders.Blizzard = M
table.insert(fsProviders.All, M)

local function RequestSort()
    for _, callback in pairs(sortCallbacks) do
        callback(M)
    end
end

local function RequestUpdateContainers()
    for _, callback in pairs(containersChangedCallbacks) do
        callback(M)
    end
end

local function OnEvent(_, event)
    RequestSort()

    if event == events.EDIT_MODE_LAYOUTS_UPDATED then
        RequestUpdateContainers()
    end
end

local function OnCvarUpdate(_, _, name)
    for _, cvar in ipairs(cvarsToUpdateContainer) do
        if name == cvar then
            RequestUpdateContainers()
            return
        end
    end

    for _, pattern in ipairs(cvarsPatternsToRunSort) do
        if string.match(name, pattern) then
            RequestSort()
            return
        end
    end
end

local function GetOffset(container)
    if container and container.title and type(container.title) == "table" and type(container.title.GetHeight) == "function" then
        return {
            X = 0,
            Y = -container.title:GetHeight()
        }
    end

    return nil
end

local function OnRaidGroupLoaded(_)
    -- refresh group frame offsets once a group has been loaded
    RequestUpdateContainers()
end

function M:Name()
    return "Blizzard"
end

function M:Enabled()
    local containers = M:Containers()

    for _, container in ipairs(containers) do
        -- frame addons will usually disable blizzard via unsubscribing group update events
        if container.Frame:IsVisible() or container.Frame:IsEventRegistered("GROUP_ROSTER_UPDATE") then
            return true
        end
    end

    return false
end

function M:Init()
    if not M:Enabled() then
        return
    end

    if #sortCallbacks > 0 then
        sortCallbacks = {}
    end

    if #containersChangedCallbacks > 0 then
        containersChangedCallbacks = {}
    end

    eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)
    eventFrame:RegisterEvent(events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(events.PLAYER_ROLES_ASSIGNED)
    eventFrame:RegisterEvent(events.UNIT_PET)

    if wow.IsRetail() then
        wow.EventRegistry:RegisterCallback(events.EditModeExit, RequestSort)
        -- user may have changed frame settings, so request that containers be refreshed
        wow.EventRegistry:RegisterCallback(events.EditModeExit, RequestUpdateContainers)
        eventFrame:RegisterEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
        eventFrame:RegisterEvent(events.ARENA_OPPONENT_UPDATE)

        fsScheduler:RunWhenEnteringWorld(function()
            -- this event always fires when loading
            -- and we don't care about the first one
            -- so to avoid running modules multiple times on first load, delay the event registration
            eventFrame:RegisterEvent(events.EDIT_MODE_LAYOUTS_UPDATED)
        end)
    end

    local cvarUpdate = wow.CreateFrame("Frame")
    cvarUpdate:HookScript("OnEvent", OnCvarUpdate)
    cvarUpdate:RegisterEvent(events.CVAR_UPDATE)

    wow.hooksecurefunc("CompactRaidGroup_OnLoad", OnRaidGroupLoaded)
end

function M:RegisterRequestSortCallback(callback)
    sortCallbacks[#sortCallbacks + 1] = callback
end

function M:RegisterContainersChangedCallback(callback)
    containersChangedCallbacks[#containersChangedCallbacks + 1] = callback
end

function M:Containers()
    ---@type FrameContainer
    local party = {
        Frame = wow.CompactPartyFrame,
        Type = fsFrame.ContainerType.Party,
        LayoutType = fsFrame.LayoutType.Hard,
        VisibleOnly = true,
        SupportsSpacing = true,
        IsGrouped = function() return false end,
        IsHorizontalLayout = function()
            if wow.IsRetail() then
                return wow.EditModeManagerFrame:GetSettingValueBool(
                    wow.Enum.EditModeSystem.UnitFrame,
                    wow.Enum.EditModeUnitFrameSystemIndices.Party,
                    wow.Enum.EditModeUnitFrameSetting.UseHorizontalGroups)
            end

            return wow.CompactRaidFrameManager_GetSetting("HorizontalGroups")
        end,
        FramesOffset = function()
            return GetOffset(wow.CompactPartyFrame)
        end,

        -- not applicable
        GroupFramesOffset = function(_) return nil end,
        FramesPerLine = function(_) return nil end
    }

    ---@type FrameContainer
    local raid = {
        Frame = wow.CompactRaidFrameContainer,
        Type = fsFrame.ContainerType.Raid,
        LayoutType = fsFrame.LayoutType.Hard,
        VisibleOnly = true,
        SupportsSpacing = true,
        IsGrouped = function()
            if wow.IsRetail() then
                local raidGroupDisplayType = wow.EditModeManagerFrame:GetSettingValue(
                    wow.Enum.EditModeSystem.UnitFrame,
                    wow.Enum.EditModeUnitFrameSystemIndices.Raid,
                    wow.Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
                return raidGroupDisplayType == wow.Enum.RaidGroupDisplayType.SeparateGroupsVertical or raidGroupDisplayType == wow.Enum.RaidGroupDisplayType.SeparateGroupsHorizontal
            end

            return wow.CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
        end,
        IsHorizontalLayout = function()
            if wow.IsRetail() then
                local displayType = wow.EditModeManagerFrame:GetSettingValue(
                    wow.Enum.EditModeSystem.UnitFrame,
                    wow.Enum.EditModeUnitFrameSystemIndices.Raid,
                    wow.Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
                return displayType == wow.Enum.RaidGroupDisplayType.SeparateGroupsHorizontal or displayType == wow.Enum.RaidGroupDisplayType.CombineGroupsHorizontal
            end

            return wow.CompactRaidFrameManager_GetSetting("HorizontalGroups")
        end,
        FramesOffset = function()
            return GetOffset(wow.CompactRaidFrameContainer)
        end,
        GroupFramesOffset = function()
            local groups = fsFrame:ExtractGroups(wow.CompactRaidFrameContainer)

            if #groups == 0 then
                return nil
            end

            return GetOffset(groups[1])
        end,
        FramesPerLine = function()
            return wow.CompactRaidFrameContainer and wow.CompactRaidFrameContainer.flowMaxPerLine
        end
    }

    ---@type FrameContainer
    local arena = {
        Frame = wow.CompactArenaFrame,
        Type = fsFrame.ContainerType.EnemyArena,
        LayoutType = fsFrame.LayoutType.Soft,
        VisibleOnly = true,
        SupportsSpacing = true,
        FramesOffset = function()
            return GetOffset(wow.CompactArenaFrame)
        end,

        -- not applicable
        IsHorizontalLayout = function() return nil end,
        IsGrouped = function() return nil end,
        GroupFramesOffset = function(_) return nil end,
        FramesPerLine = function(_) return nil end
    }

    return fsEnumerable:From({
            party,
            raid,
            arena
        })
        :Where(function(x) return x.Frame ~= nil end)
        :ToTable()
end
