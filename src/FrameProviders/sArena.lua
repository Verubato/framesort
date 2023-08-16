local _, addon = ...
---@type WoW
local wow = addon.WoW
local fsFrame = addon.Frame
local fsScheduler = addon.Scheduler
local M = {}
local callbacks = {}

fsFrame.Providers.sArena = M
table.insert(fsFrame.Providers.All, M)

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
    if wow.WOW_PROJECT_ID ~= wow.WOW_PROJECT_MAINLINE then
        return false
    end

    return wow.GetAddOnEnableState(nil, "sArena Updated") ~= 0
end

function M:Init()
    if not M:Enabled() then
        return
    end

    local eventFrame = wow.CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", UpdateNextFrame)
    eventFrame:RegisterEvent(addon.Events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
    eventFrame:RegisterEvent(addon.Events.ARENA_OPPONENT_UPDATE)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ENTERING_WORLD)
end

function M:RegisterCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function M:GetUnit(frame)
    return GetUnit(frame)
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
    ---@diagnostic disable-next-line: undefined-global
    return fsFrame:ChildUnitFrames(sArena, GetUnit)
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
