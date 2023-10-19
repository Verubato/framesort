---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsScheduler = addon.Scheduling.Scheduler
local fsProviders = addon.Providers
local events = addon.WoW.Api.Events
local M = {}
local callbacks = {}
local containersChangedCallbacks = {}
local eventFrame = nil

fsProviders.GladiusEx = M
table.insert(fsProviders.All, M)

local function RequestSort()
    for _, callback in pairs(callbacks) do
        callback(M)
    end
end

local function RequestUpdateContainers()
    for _, callback in pairs(containersChangedCallbacks) do
        callback(M)
    end
end

local function UpdateNextFrame()
    -- wait for GladiusEx to update their frames before we perform a sort
    -- technically waiting until next frame may not be required as we reigstered our callbacks after GEX
    -- which means blizzard should invoke our callbacks after gladius
    -- but it's probably best not to rely on this, so just run our sorting next frame
    fsScheduler:RunNextFrame(RequestSort)
end

local function DelayedInit()
    assert(eventFrame ~= nil)

    eventFrame:RegisterEvent(events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(events.PLAYER_ROLES_ASSIGNED)
    eventFrame:RegisterEvent(events.UNIT_PET)

    if wow.IsRetail() then
        eventFrame:RegisterEvent(events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
        eventFrame:RegisterEvent(events.ARENA_OPPONENT_UPDATE)
    end

    RequestUpdateContainers()
end

local function OnEvent()
    UpdateNextFrame()
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

    eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnEvent)

    -- wait for GladiusEx to initialise before we do
    fsScheduler:RunWhenEnteringWorld(DelayedInit)
end

function M:RegisterRequestSortCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function M:RegisterContainersChangedCallback(callback)
    containersChangedCallbacks[#containersChangedCallbacks + 1] = callback
end

function M:Containers()
    ---@type FrameContainer[]
    local containers = {}

    if GladiusExPartyFrame then
        containers[#containers + 1] = {
            Frame = GladiusExPartyFrame,
            Type = fsFrame.ContainerType.Party,
            LayoutType = fsFrame.LayoutType.Soft,
            SupportsSpacing = false,

            -- not applicable
            FramesOffset = function() return nil end,
            IsGrouped = function() return nil end,
            IsHorizontalLayout = function() return nil end,
            GroupFramesOffset = function(_) return nil end,
            FramesPerLine = function(_) return nil end
        }
    end

    if GladiusExArenaFrame then
        containers[#containers + 1] = {
            Frame = GladiusExArenaFrame,
            Type = fsFrame.ContainerType.EnemyArena,
            LayoutType = fsFrame.LayoutType.Soft,
            SupportsSpacing = false,

            -- not applicable
            FramesOffset = function() return nil end,
            IsGrouped = function() return nil end,
            IsHorizontalLayout = function() return nil end,
            GroupFramesOffset = function(_) return nil end,
            FramesPerLine = function(_) return nil end
        }
    end

    return containers
end
