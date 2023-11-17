---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsProviders = addon.Providers
local fsUnit = addon.WoW.Unit
local fsEnumerable = addon.Collections.Enumerable
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

local function WhereVisible(frames)
    return fsEnumerable
        :From(frames)
        :Where(function(x)
            return x:IsVisible()
        end)
        :ToTable()
end

local function GetFriendlyFrames(provider)
    local frames = WhereVisible(fsFrame:PartyFrames(provider))

    if #frames == 0 then
        frames = WhereVisible(fsFrame:RaidFrames(provider))
    end

    return frames
end

local function UpdateTargets()
    local start = wow.GetTimePreciseSec()
    local friendlyUnits = M:FriendlyUnits()
    local updatedCount = 0

    -- if units has less than 5 items it's still fine as units[i] will just be nil
    for i, btn in ipairs(targetFramesButtons) do
        local new = friendlyUnits[i] or "none"
        local current = btn:GetAttribute("unit")

        if current ~= new then
            btn:SetAttribute("unit", new)
            updatedCount = updatedCount + 1
        end
    end

    assert(targetBottomFrameButton ~= nil)
    local bottomCurrentUnit = targetBottomFrameButton:GetAttribute("unit")
    local bottomNewUnit = friendlyUnits[#friendlyUnits] or "none"

    if bottomCurrentUnit ~= bottomNewUnit then
        targetBottomFrameButton:SetAttribute("unit", bottomNewUnit)
        updatedCount = updatedCount + 1
    end

    local enemyunits = M:EnemyUnits()

    for i, btn in ipairs(targetEnemyButtons) do
        local new = enemyunits[i] or "none"
        local current = btn:GetAttribute("unit")

        if current ~= new then
            btn:SetAttribute("unit", new)
            updatedCount = updatedCount + 1
        end
    end

    for i, btn in ipairs(focusEnemyButtons) do
        local new = enemyunits[i] or "none"
        local current = btn:GetAttribute("unit")

        if current ~= new then
            btn:SetAttribute("unit", new)
            updatedCount = updatedCount + 1
        end
    end

    local stop = wow.GetTimePreciseSec()
    fsLog:Debug(string.format("Update targets took %fms, %d updated.", (stop - start) * 1000, updatedCount))
end

function M:FriendlyFrames()
    local frames = nil

    -- prefer Blizzard frames
    if fsProviders.Blizzard:Enabled() then
        frames = GetFriendlyFrames(fsProviders.Blizzard)
    end

    if not frames or #frames == 0 then
        local nonBlizzard = fsEnumerable
            :From(fsProviders:Enabled())
            :Where(function(provider)
                return provider ~= fsProviders.Blizzard
            end)
            :ToTable()

        for _, provider in ipairs(nonBlizzard) do
            frames = GetFriendlyFrames(provider)

            if #frames > 0 then
                break
            end
        end
    end

    if not frames or #frames == 0 then
        return {}
    end

    return fsEnumerable
        :From(frames)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()
end

function M:FriendlyUnits()
    local frames = M:FriendlyFrames()

    if frames and #frames > 0 then
       return fsEnumerable
            :From(frames)
            :Map(function(x)
                return fsFrame:GetFrameUnit(x)
            end)
            :ToTable()
    end

    -- no frames found, fallback to units
    local units = fsUnit:FriendlyUnits()
    local sortEnabled = fsCompare:FriendlySortMode()

    if not sortEnabled then
        return units
    end

    table.sort(units, fsCompare:SortFunction(units))

    return units
end

function M:EnemyFrames()
    -- GladiusEx, sArena, and Blizzar all show enemies in group order
    -- arena1, arena2, arena3
    -- so we can just grab the units directly instead of extracting units from frames
    -- this has the benefit of not having to worry about frame visibility and event ordering shenanigans
    local units = fsUnit:EnemyUnits()
    local sortEnabled = fsCompare:EnemySortMode()

    if not sortEnabled then
        return units
    end

    table.sort(units, fsCompare:EnemySortFunction())

    return units
end

function M:EnemyUnits()
    -- GladiusEx, sArena, and Blizzar all show enemies in group order
    -- arena1, arena2, arena3
    -- so we can just grab the units directly instead of extracting units from frames
    -- this has the benefit of not having to worry about frame visibility and event ordering shenanigans
    local units = fsUnit:EnemyUnits()

    -- EnemyUnits() returns in group order
    local sortEnabled = fsCompare:EnemySortMode()

    if not sortEnabled then
        return units
    end

    table.sort(units, fsCompare:EnemySortFunction())

    return units
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
