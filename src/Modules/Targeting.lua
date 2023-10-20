---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsProviders = addon.Providers
local fsUnit = addon.WoW.Unit
local fsEnumerable = addon.Collections.Enumerable
local fsScheduler = addon.Scheduling.Scheduler
local fsCompare = addon.Collections.Comparer
local fsFrame = addon.WoW.Frame
local fsLog = addon.Logging.Log
local targetFramesButtons = {}
local targetEnemyButtons = {}
local focusEnemyButtons = {}
local targetBottomFrameButton = nil

---@class TargetingModule: IInitialise
local M = {}
addon.Modules.Targeting = M

local function GetFriendlyFrames(provider)
    local whereVisible = function(frames)
        return fsEnumerable
            :From(frames)
            :Where(function(x)
                return x:IsVisible()
            end)
            :ToTable()
    end

    local frames = whereVisible(fsFrame:PartyFrames(provider))

    if #frames == 0 then
        frames = whereVisible(fsFrame:RaidFrames(provider))
    end

    return frames
end

local function UpdateTargets()
    local start = wow.GetTimePreciseSec()
    local friendlyUnits = M:FriendlyTargets()
    local updatedAny = false

    -- if units has less than 5 items it's still fine as units[i] will just be nil
    for i, btn in ipairs(targetFramesButtons) do
        local new = friendlyUnits[i] or "none"
        local current = btn:GetAttribute("unit")

        if current ~= new then
            btn:SetAttribute("unit", new)
            updatedAny = true
        end
    end

    assert(targetBottomFrameButton ~= nil)
    local bottomCurrentUnit = targetBottomFrameButton:GetAttribute("unit")
    local bottomNewUnit = friendlyUnits[#friendlyUnits] or "none"

    if bottomCurrentUnit ~= bottomNewUnit then
        targetBottomFrameButton:SetAttribute("unit", bottomNewUnit)
        updatedAny = true
    end

    local enemyunits = M:EnemyTargets()

    for i, btn in ipairs(targetEnemyButtons) do
        local new = enemyunits[i] or "none"
        local current = btn:GetAttribute("unit")

        if current ~= new then
            btn:SetAttribute("unit", new)
            updatedAny = true
        end
    end

    for i, btn in ipairs(focusEnemyButtons) do
        local new = enemyunits[i] or "none"
        local current = btn:GetAttribute("unit")

        if current ~= new then
            btn:SetAttribute("unit", new)
            updatedAny = true
        end
    end

    if updatedAny then
        fsLog:Debug(string.format("Updated targets: %d friendly, %d enemy.", #friendlyUnits, #enemyunits))
    end

    local stop = wow.GetTimePreciseSec()
    fsLog:Debug(string.format("Update targets took %fms.", (stop - start) * 1000))
end

function M:FriendlyTargets()
    local frames = nil
    local frameProvider = nil

    -- prefer Blizzard frames
    if fsProviders.Blizzard:Enabled() then
        frames = GetFriendlyFrames(fsProviders.Blizzard)
        frameProvider = fsProviders.Blizzard
    end

    if not frames or #frames == 0 then
        for _, provider in pairs(fsProviders:Enabled()) do
            frames = GetFriendlyFrames(provider)
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
                return fsFrame:GetFrameUnit(x)
            end)
            :ToTable()
    end

    -- fallback to party/raid123
    -- TODO: sort the units array
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

    for _, provider in pairs(preferred) do
        frames = fsEnumerable
            :From(fsFrame:EnemyArenaFrames(provider))
            :Where(function(x)
                return x:IsVisible()
            end)
            :ToTable()

        if #frames > 0 then
            break
        end
    end

    if #frames == 0 and fsProviders.Blizzard:Enabled() then
        frames = fsEnumerable
            :From(fsFrame:EnemyArenaFrames(fsProviders.Blizzard))
            :Where(function(x)
                return x:IsVisible()
            end)
            :ToTable()
    end

    if #frames > 0 then
        return fsEnumerable
            :From(frames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x, y)
            end)
            :Map(function(x)
                return fsFrame:GetFrameUnit(x)
            end)
            :ToTable()
    end

    -- fallback to arena123
    -- TODO: sort the units array
    return fsUnit:EnemyUnits(false)
end

function M:Run()
    assert(not wow.InCombatLockdown())

    UpdateTargets()
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
        local button = wow.CreateFrame("Button", "FSTarget" .. i, wow.UIParent, "SecureActionButtonTemplate")
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
        local target = wow.CreateFrame("Button", "FSTargetEnemy" .. i, wow.UIParent, "SecureActionButtonTemplate")
        target:RegisterForClicks("AnyDown", "AnyUp")
        target:SetAttribute("type", "target")
        target:SetAttribute("unit", "none")

        local focus = wow.CreateFrame("Button", "FSFocusEnemy" .. i, wow.UIParent, "SecureActionButtonTemplate")
        focus:RegisterForClicks("AnyDown", "AnyUp")
        focus:SetAttribute("type", "focus")
        focus:SetAttribute("unit", "none")

        targetEnemyButtons[#targetEnemyButtons + 1] = target
        focusEnemyButtons[#focusEnemyButtons + 1] = focus
    end

    -- target bottom
    targetBottomFrameButton = wow.CreateFrame("Button", "FSTargetBottom", wow.UIParent, "SecureActionButtonTemplate")
    targetBottomFrameButton:RegisterForClicks("AnyDown", "AnyUp")
    targetBottomFrameButton:SetAttribute("type", "target")
    targetBottomFrameButton:SetAttribute("unit", "none")
end
