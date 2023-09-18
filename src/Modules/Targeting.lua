---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsProviders = addon.Providers
local fsUnit = addon.WoW.Unit
local fsSort = addon.Modules.Sorting
local fsEnumerable = addon.Collections.Enumerable
local fsScheduler = addon.Scheduling.Scheduler
local fsCompare = addon.Collections.Comparer
local fsLog = addon.Logging.Log
local prefix = "FSTarget"
local targetFramesButtons = {}
local targetEnemyButtons = {}
local targetBottomFrameButton = nil
---@class TargetingModule: Initialise
local M = {}
addon.Modules.Targeting = M

local function GetFrames(provider)
    local whereVisible = function(frames)
        return fsEnumerable
            :From(frames)
            :Where(function(x)
                return x:IsVisible()
            end)
            :ToTable()
    end

    local frames = whereVisible(provider:PartyFrames())

    if #frames == 0 then
        if not provider:IsRaidGrouped() then
            frames = whereVisible(provider:RaidFrames())
        else
            frames = whereVisible(fsEnumerable
                :From(provider:RaidGroups())
                :Map(function(group)
                    return provider:RaidGroupMembers(group)
                end)
                :Flatten())
        end
    end

    return frames
end

local function UpdateTargets()
    local friendlyUnits = M:FriendlyTargets()

    -- if units has less than 5 items it's still fine as units[i] will just be nil
    for i, btn in ipairs(targetFramesButtons) do
        local unit = friendlyUnits[i]

        btn:SetAttribute("unit", unit or "none")
    end

    assert(targetBottomFrameButton ~= nil)
    targetBottomFrameButton:SetAttribute("unit", friendlyUnits[#friendlyUnits] or "none")

    local enemyunits = M:EnemyTargets()

    for i, btn in ipairs(targetEnemyButtons) do
        local unit = enemyunits[i]

        btn:SetAttribute("unit", unit or "none")
    end

    return true
end

local function Run()
    if wow.InCombatLockdown() then
        fsLog:Warning("Can't update targets during combat.")
        fsScheduler:RunWhenCombatEnds(UpdateTargets, "UpdateTargets")
        return
    end

    UpdateTargets()
end

function M:FriendlyTargets()
    local frames = nil
    local frameProvider = nil

    -- prefer Blizzard frames
    if fsProviders.Blizzard:Enabled() then
        frames = GetFrames(fsProviders.Blizzard)
        frameProvider = fsProviders.Blizzard
    end

    if not frames or #frames == 0 then
        for _, provider in pairs(fsProviders:Enabled()) do
            frames = GetFrames(provider)
            frameProvider = provider

            if #frames > 0 then
                break
            end
        end
    end

    if frames and #frames > 0 and frameProvider then
        return fsEnumerable
            :From(frames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x, y)
            end)
            :Map(function(x)
                return frameProvider:GetUnit(x)
            end)
            :ToTable()
    end

    -- fallback to party/raid123
    return fsUnit:FriendlyUnits()
end

function M:EnemyTargets()
    -- prefer GladiusEx/sArena
    local preferred = fsEnumerable
        :From(fsProviders:Enabled())
        :Where(function(provider)
            return provider ~= fsProviders.Blizzard
        end)
        :ToTable()

    local frames = {}
    local frameProvider = nil

    for _, provider in pairs(preferred) do
        frames = fsEnumerable
            :From(provider:EnemyArenaFrames())
            :Where(function(x)
                return x:IsVisible()
            end)
            :ToTable()
        frameProvider = provider

        if #frames > 0 then
            break
        end
    end

    if #frames == 0 and fsProviders.Blizzard:Enabled() then
        frames = fsEnumerable
            :From(fsProviders.Blizzard:EnemyArenaFrames())
            :Where(function(x)
                return x:IsVisible()
            end)
            :ToTable()

        frameProvider = fsProviders.Blizzard
    end

    if #frames > 0 then
        return fsEnumerable
            :From(frames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x, y)
            end)
            :Map(function(x)
                return frameProvider:GetUnit(x)
            end)
            :ToTable()
    end

    -- fallback to arena123
    return fsUnit:EnemyUnits()
end

function M:Init()
    local targetFriendlyCount = 5
    local targetEnemyCount = 3

    if #targetFramesButtons > 0 then
        targetFramesButtons = {}
    end
    if #targetEnemyButtons > 0 then
        targetEnemyButtons = {}
    end

    for i = 1, targetFriendlyCount do
        local button = wow.CreateFrame("Button", prefix .. i, wow.UIParent, "SecureActionButtonTemplate")
        -- If the ActionButtonUseKeyDown cvar is set to 0, then button down triggers don't work
        -- seems to be a Blizzard bug since Dragonflight:
        -- https://us.forums.blizzard.com/en/wow/t/dragonflight-click-bindings-broken/1361972/8
        -- Adding "AnyUp" fixes it
        button:RegisterForClicks("AnyDown", "AnyUp")
        button:SetAttribute("type", "target")
        button:SetAttribute("unit", "none")

        targetFramesButtons[#targetFramesButtons + 1] = button
    end

    for i = 1, targetEnemyCount do
        local button = wow.CreateFrame("Button", prefix .. "Enemy" .. i, wow.UIParent, "SecureActionButtonTemplate")
        button:RegisterForClicks("AnyDown", "AnyUp")
        button:SetAttribute("type", "target")
        button:SetAttribute("unit", "none")

        targetEnemyButtons[#targetEnemyButtons + 1] = button
    end

    -- target bottom
    targetBottomFrameButton = wow.CreateFrame("Button", prefix .. "Bottom", wow.UIParent, "SecureActionButtonTemplate")
    targetBottomFrameButton:RegisterForClicks("AnyDown", "AnyUp")
    targetBottomFrameButton:SetAttribute("type", "target")
    targetBottomFrameButton:SetAttribute("unit", "none")

    for _, provider in ipairs(fsProviders:Enabled()) do
        provider:RegisterCallback(Run)
    end

    fsSort:RegisterPostSortCallback(Run)
end
