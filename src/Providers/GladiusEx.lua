---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsScheduler = addon.Scheduling.Scheduler
local fsProviders = addon.Providers
local events = addon.WoW.Api.Events
local M = {}
local callbacks = {}

fsProviders.GladiusEx = M
table.insert(fsProviders.All, M)

local function RequestSort()
    for _, callback in pairs(callbacks) do
        callback(M)
    end
end

local function UpdateNextFrame()
    -- wait for GladiusEx to update their frames before we perform a sort
    fsScheduler:RunNextFrame(RequestSort)
end

function M:Name()
    return "GladiusEx"
end

function M:Enabled()
    return wow.IsRetail() and wow.GetAddOnEnableState(nil, "GladiusEx") ~= 0
end

function M:Init()
    if not M:Enabled() then
        return
    end

    if #callbacks > 0 then
        callbacks = {}
    end

    local eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", UpdateNextFrame)
    eventFrame:RegisterEvent(events.PLAYER_ENTERING_WORLD)
    eventFrame:RegisterEvent(events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(events.PLAYER_ROLES_ASSIGNED)
    eventFrame:RegisterEvent(events.UNIT_PET)

    if wow.IsRetail() then
        eventFrame:RegisterEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
        eventFrame:RegisterEvent(events.ARENA_OPPONENT_UPDATE)
    end
end

function M:RegisterRequestSortCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function M:RegisterContainersChangedCallback(_) end

function M:Containers()
    ---@type FrameContainer[]
    local containers = {}

    ---@diagnostic disable-next-line: undefined-global
    if GladiusExPartyFrame then
        containers[#containers + 1] = {
            ---@diagnostic disable-next-line: undefined-global
            Frame = GladiusExPartyFrame,
            Type = fsFrame.ContainerType.Party,
            LayoutType = fsFrame.LayoutType.Soft,
            SupportsSpacing = false,

            -- not applicable
            FramesOffset = function() return nil end,
            SupportsGrouping = function() return nil end,
            IsHorizontalLayout = function() return nil end,
            GroupFramesOffset = function(_) return nil end
        }
    end

    ---@diagnostic disable-next-line: undefined-global
    if GladiusExArenaFrame then
        containers[#containers + 1] = {
            ---@diagnostic disable-next-line: undefined-global
            Frame = GladiusExArenaFrame,
            Type = fsFrame.ContainerType.EnemyArena,
            LayoutType = fsFrame.LayoutType.Soft,
            SupportsSpacing = false,

            -- not applicable
            FramesOffset = function() return nil end,
            SupportsGrouping = function() return nil end,
            IsHorizontalLayout = function() return nil end,
            GroupFramesOffset = function(_) return nil end
        }
    end

    return containers
end
