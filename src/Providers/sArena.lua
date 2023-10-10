---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsScheduler = addon.Scheduling.Scheduler
local fsProviders = addon.Providers
local events = addon.WoW.Api.Events
local M = {}
local callbacks = {}

fsProviders.sArena = M
table.insert(fsProviders.All, M)

local function RequestSort()
    for _, callback in pairs(callbacks) do
        callback(M)
    end
end

local function UpdateNextFrame()
    -- wait for sArena to update their frames before we perform a sort
    fsScheduler:RunNextFrame(RequestSort)
end

function M:Name()
    return "sArena"
end

function M:Enabled()
    return wow.IsRetail() and wow.GetAddOnEnableState(nil, "sArena Updated") ~= 0
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
    ---@diagnostic disable-next-line: undefined-global
    if not sArena then
        return {}
    end

    ---@type FrameContainer
    local arena = {
        ---@diagnostic disable-next-line: undefined-global
        Frame = sArena,
        Type = fsFrame.ContainerType.EnemyArena,
        LayoutType = fsFrame.LayoutType.Soft,
        SupportsSpacing = false,

        -- not applicable
        FramesOffset = function() return nil end,
        SupportsGrouping = function() return nil end,
        IsHorizontalLayout = function() return nil end,
        GroupFramesOffset = function(_) return nil end
    }

    return {
        arena
    }
end
