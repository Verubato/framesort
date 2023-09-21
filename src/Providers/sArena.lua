---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsScheduler = addon.Scheduling.Scheduler
local fsProviders = addon.Providers
local fsConfig = addon.Configuration
local events = addon.WoW.Api.Events
local M = {}
local callbacks = {}

fsProviders.sArena = M
table.insert(fsProviders.All, M)

local function GetUnit(frame)
    return frame.unit
end

local function Update()
    for _, callback in pairs(callbacks) do
        callback(M)
    end
end

local function UpdateNextFrame()
    -- wait for sArena to update their frames before we perform a sort
    fsScheduler:RunNextFrame(Update)
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

function M:RegisterCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function M:GetUnit(frame)
    return GetUnit(frame)
end

function M:PartyContainer()
    return nil
end

function M:EnemyArenaContainer()
    ---@diagnostic disable-next-line: undefined-global
    return sArena
end

function M:RaidContainer()
    return nil
end

function M:PartyFrames()
    return {}
end

function M:RaidFrames()
    return {}
end

function M:RaidGroupMembers(_)
    return {}
end

function M:RaidGroups()
    return {}
end

function M:EnemyArenaFrames()
    return fsFrame:ChildUnitFrames(M:EnemyArenaContainer(), GetUnit)
end

function M:ShowPartyPets()
    return false
end

function M:ShowRaidPets()
    return false
end

function M:IsRaidGrouped()
    return false
end

function M:LayoutStrategy()
    return fsConfig.LayoutStrategy.Soft
end

function M:IsPartyHorizontalLayout()
    -- not applicable as we're using the Soft layout strategy
    return false
end

function M:IsRaidHorizontalLayout()
    -- not applicable as we're using the Soft layout strategy
    return false
end

function M:IsEnemyArenaHorizontalLayout()
    -- not applicable as we're using the Soft layout strategy
    return false
end
