local _, addon = ...
local fsUnit = addon.Unit
local fsSort = addon.Sorting
local fsEnumerable = addon.Enumerable
local fsScheduler = addon.Scheduler
local fsFrame = addon.Frame
local fsCompare = addon.Compare
local fsLog = addon.Log
local prefix = "FSTarget"
local targetFriendlyCount = 5
local targetFramesButtons = {}
local targetEnemyCount = 3
local targetEnemyButtons = {}
local targetBottomFrameButton = nil
local M = {}
addon.Target = M

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

    targetBottomFrameButton:SetAttribute("unit", friendlyUnits[#friendlyUnits] or "none")

    local enemyunits = M:EnemyTargets()

    for i, btn in ipairs(targetEnemyButtons) do
        local unit = enemyunits[i]

        btn:SetAttribute("unit", unit or "none")
    end

    return true
end

local function Run()
    if InCombatLockdown() then
        fsLog:Warning("Can't update targets during combat.")
        fsScheduler:RunWhenCombatEnds(UpdateTargets)
        return
    end

    UpdateTargets()
end

function M:FriendlyTargets()
    local frames = nil
    local frameProvider = nil

    -- prefer Blizzard frames
    if fsFrame.Providers.Blizzard:Enabled() then
        frames = GetFrames(fsFrame.Providers.Blizzard)
        frameProvider = fsFrame.Providers.Blizzard
    end

    if not frames or #frames == 0 then
        for _, provider in pairs(fsFrame.Providers:Enabled()) do
            frames = GetFrames(provider)
            frameProvider = provider

            if #frames > 0 then
                break
            end
        end
    end

    if frames and #frames > 0 then
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
        :From(fsFrame.Providers:Enabled())
        :Where(function(provider)
            return provider ~= fsFrame.Providers.Blizzard
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

    if #frames == 0 and fsFrame.Providers.Blizzard:Enabled() then
        frames = fsEnumerable
            :From(fsFrame.Providers.Blizzard:EnemyArenaFrames())
            :Where(function(x)
                return x:IsVisible()
            end)
            :ToTable()

        frameProvider = fsFrame.Providers.Blizzard
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

---Initialises the targeting frames feature.
function addon:InitTargeting()
    for i = 1, targetFriendlyCount do
        local button = CreateFrame("Button", prefix .. i, UIParent, "SecureActionButtonTemplate")
        button:RegisterForClicks("AnyDown")
        button:SetAttribute("type", "target")
        button:SetAttribute("unit", "none")

        targetFramesButtons[#targetFramesButtons + 1] = button
    end

    for i = 1, targetEnemyCount do
        local button = CreateFrame("Button", prefix .. "Enemy" .. i, UIParent, "SecureActionButtonTemplate")
        button:RegisterForClicks("AnyDown")
        button:SetAttribute("type", "target")
        button:SetAttribute("unit", "none")

        targetEnemyButtons[#targetEnemyButtons + 1] = button
    end

    -- target bottom
    targetBottomFrameButton = CreateFrame("Button", prefix .. "Bottom", UIParent, "SecureActionButtonTemplate")
    targetBottomFrameButton:RegisterForClicks("AnyDown")
    targetBottomFrameButton:SetAttribute("type", "target")
    targetBottomFrameButton:SetAttribute("unit", "none")

    for _, provider in ipairs(fsFrame.Providers:Enabled()) do
        provider:RegisterCallback(Run)
    end

    fsSort:RegisterPostSortCallback(Run)
end
