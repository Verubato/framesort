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

    local enemyunits = M:EnemyTargets()

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

function M:FriendlyTargets()
    local frames = nil

    -- prefer Blizzard frames
    if fsProviders.Blizzard:Enabled() then
        frames = GetFriendlyFrames(fsProviders.Blizzard)
    end

    local nonBlizzard = fsEnumerable
        :From(fsProviders:Enabled())
        :Where(function(provider)
            return provider ~= fsProviders.Blizzard
        end)
        :ToTable()

    if not frames or #frames == 0 then
        for _, provider in ipairs(nonBlizzard) do
            frames = GetFriendlyFrames(provider)

            if #frames > 0 then
                break
            end
        end
    end

    local units = nil

    if frames and #frames > 0 then
        units = fsEnumerable
            :From(frames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x, y)
            end)
            :Map(function(x)
                return fsFrame:GetFrameUnit(x)
            end)
            :ToTable()
    end

    if units and #units > 0 then
        return units
    end

    -- no frames found, fallback to units
    units = fsUnit:FriendlyUnits()

    local sortEnabled = fsCompare:FriendlySortMode()

    if not sortEnabled then
        return units
    end

    table.sort(units, fsCompare:SortFunction(units))

    return units
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

    for _, provider in ipairs(preferred) do
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

    local units = nil

    if #frames > 0 then
        units = fsEnumerable
            :From(frames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x, y)
            end)
            :Map(function(x)
                return fsFrame:GetFrameUnit(x)
            end)
            :ToTable()
    end

    if units and #units > 0 then
        return units
    end

    -- get enemy units even if they don't exist
    -- as we might be in the starting room of the arena where UnitExists() will return false until gates open
    units = fsUnit:EnemyUnits(false)

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
