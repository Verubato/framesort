local _, addon = ...
local fsUnit = addon.Unit
local fsSort = addon.Sorting
local fsEnumerable = addon.Enumerable
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

local function CanUpdate()
    if InCombatLockdown() then
        fsLog:Warning("Can't update targets during combat.")
        return false
    end

    return true
end

local function GetFrames(provider)
    local frames = {}
    if provider:PartyFramesEnabled() then
        frames = provider:PartyFrames()
    elseif provider:RaidFramesEnabled() then
        frames = fsFrame:AllRaidFrames(provider)
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
    if not CanUpdate() then
        return
    end

    UpdateTargets()
end

function M:FriendlyTargets()
    -- prefer Blizzard frames
    local frames = GetFrames(fsFrame.Providers.Blizzard)
    local frameProvider = fsFrame.Providers.Blizzard

    if #frames == 0 then
        for _, provider in pairs(fsFrame.Providers:Enabled()) do
            frames = GetFrames(provider)
            frameProvider = provider

            if #frames > 0 then
                break
            end
        end
    end

    if #frames > 0 then
        return fsEnumerable
            :From(frames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x.Frame, y.Frame)
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
            return provider ~= fsFrame.Providers.Blizzard and provider:EnemyArenaFramesEnabled()
        end)
        :ToTable()

    local frames = {}
    local frameProvider = nil

    for _, provider in pairs(preferred) do
        frames = provider:EnemyArenaFrames()
        frameProvider = provider

        if #frames > 0 then
            break
        end
    end

    if #frames == 0 then
        frames = GetFrames(fsFrame.Providers.Blizzard)
        frameProvider = fsFrame.Providers.Blizzard
    end

    if #frames > 0 then
        return fsEnumerable
            :From(frames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x.Frame, y.Frame)
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

    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", Run)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ENTERING_WORLD)
    eventFrame:RegisterEvent(addon.Events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(addon.Events.PLAYER_REGEN_ENABLED)

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        eventFrame:RegisterEvent(addon.Events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
        eventFrame:RegisterEvent(addon.Events.ARENA_OPPONENT_UPDATE)
    end

    fsSort:RegisterPostSortCallback(Run)
end
