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
local targetPetFramesButtons = {}
local targetEnemyButtons = {}
local targetEnemyPetButtons = {}
local focusEnemyButtons = {}
local targetBottomFrameButton = nil
local cycleNextFrameButton = nil
local cyclePreviousFrameButton = nil

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

local function UpdateCycleTargets(friendlyUnits)
    assert(cycleNextFrameButton)
    assert(cyclePreviousFrameButton)

    cycleNextFrameButton:SetAttribute("FSUnitsCount", #friendlyUnits)
    cyclePreviousFrameButton:SetAttribute("FSUnitsCount", #friendlyUnits)

    for index, unit in ipairs(friendlyUnits) do
        -- need to prefix as Unit1/2/3 is reserved
        cycleNextFrameButton:SetAttribute("FSUnit" .. index, unit)
        cyclePreviousFrameButton:SetAttribute("FSUnit" .. index, unit)
    end
end

local function UpdateTargets()
    local updatedCount = 0
    local start = wow.GetTimePreciseSec()
    local friendlyUnits = M:FriendlyUnits()

    -- if units has less than 5 items it's still fine as units[i] will just be nil
    for i, btn in ipairs(targetFramesButtons) do
        local new = friendlyUnits[i] or "none"
        local current = btn:GetAttribute("unit")

        if current ~= new then
            btn:SetAttribute("unit", new)
            updatedCount = updatedCount + 1
        end
    end

    for i, btn in ipairs(targetPetFramesButtons) do
        local new = fsUnit:PetFor(friendlyUnits[i] or "none")
        local current = btn:GetAttribute("unit")

        if current ~= new then
            btn:SetAttribute("unit", new)
            updatedCount = updatedCount + 1
        end
    end

    for i, btn in ipairs(targetFramesButtons) do
        local new = friendlyUnits[i] or "none"
        local current = btn:GetAttribute("unit")

        if current ~= new then
            btn:SetAttribute("unit", new)
            updatedCount = updatedCount + 1
        end
    end

    assert(targetBottomFrameButton)

    local bottomCurrentUnit = targetBottomFrameButton:GetAttribute("unit")
    local bottomNewUnit = friendlyUnits[#friendlyUnits] or "none"

    if bottomCurrentUnit ~= bottomNewUnit then
        targetBottomFrameButton:SetAttribute("unit", bottomNewUnit)
        updatedCount = updatedCount + 1
    end

    local enemyUnits = M:EnemyUnits()

    for i, btn in ipairs(targetEnemyButtons) do
        local new = enemyUnits[i] or "none"
        local current = btn:GetAttribute("unit")

        if current ~= new then
            btn:SetAttribute("unit", new)
            updatedCount = updatedCount + 1
        end
    end

    for i, btn in ipairs(targetEnemyPetButtons) do
        local new = fsUnit:PetFor(enemyUnits[i] or "none")
        local current = btn:GetAttribute("unit")

        if current ~= new then
            btn:SetAttribute("unit", new)
            updatedCount = updatedCount + 1
        end
    end

    for i, btn in ipairs(focusEnemyButtons) do
        local new = enemyUnits[i] or "none"
        local current = btn:GetAttribute("unit")

        if current ~= new then
            btn:SetAttribute("unit", new)
            updatedCount = updatedCount + 1
        end
    end

    UpdateCycleTargets(friendlyUnits)

    local stop = wow.GetTimePreciseSec()
    fsLog:Debug(string.format("Update targets took %fms, %d updated.", (stop - start) * 1000, updatedCount))
end

local function InitCycleButtons()
    cycleNextFrameButton = wow.CreateFrame("Button", "FSTargetNextFrame", wow.UIParent, "SecureActionButtonTemplate")
    cycleNextFrameButton:SetAttribute("type", "target")

    cyclePreviousFrameButton = wow.CreateFrame("Button", "FSTargetPreviousFrame", wow.UIParent, "SecureActionButtonTemplate")
    cyclePreviousFrameButton:SetAttribute("type", "target")

    local downOrUp = wow.GetCVarBool("ActionButtonUseKeyDown") and "AnyDown" or "AnyUp"
    cycleNextFrameButton:RegisterForClicks(downOrUp)
    cyclePreviousFrameButton:RegisterForClicks(downOrUp)

    wow.SecureHandlerSetFrameRef(cycleNextFrameButton, "PreviousHandler", cyclePreviousFrameButton)
    wow.SecureHandlerSetFrameRef(cyclePreviousFrameButton, "NextHandler", cycleNextFrameButton)

    wow.SecureHandlerWrapScript(
        cycleNextFrameButton,
        "OnClick",
        cycleNextFrameButton,
        [[
            local maxUnits = self:GetAttribute("FSUnitsCount")
            local index = (self:GetAttribute("FSIndex") or 0) + 1

            -- if we've reached the end, then start from the beginning
            if index > maxUnits then
                index = 1
            end

            local before = self:GetAttribute("unit") or "none"
            local unit = self:GetAttribute("FSUnit" .. index) or "none"

            self:SetAttribute("FSIndex", index)
            self:SetAttribute("unit", unit)

            local previousHandler = self:GetFrameRef("PreviousHandler")
            previousHandler:SetAttribute("FSIndex", index)
        ]]
    )

    wow.SecureHandlerWrapScript(
        cyclePreviousFrameButton,
        "OnClick",
        cyclePreviousFrameButton,
        [[
            local maxUnits = self:GetAttribute("FSUnitsCount")
            local index = (self:GetAttribute("FSIndex") or 0) - 1

            if index <= 0 then
                index = maxUnits
            end

            local before = self:GetAttribute("unit") or "none"
            local unit = self:GetAttribute("FSUnit" .. index) or "none"

            self:SetAttribute("FSIndex", index)
            self:SetAttribute("unit", unit)

            local nextHandler = self:GetFrameRef("NextHandler")
            nextHandler:SetAttribute("FSIndex", index)
        ]]
    )
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

        -- pet
        local pet = wow.CreateFrame("Button", "FSTargetPet" .. i, wow.UIParent, "SecureActionButtonTemplate")
        pet:RegisterForClicks("AnyDown", "AnyUp")
        pet:SetAttribute("type", "target")
        pet:SetAttribute("unit", "none")

        targetFramesButtons[i] = button
        targetPetFramesButtons[i] = pet
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

        local pet = wow.CreateFrame("Button", "FSTargetEnemyPet" .. i, wow.UIParent, "SecureActionButtonTemplate")
        pet:RegisterForClicks("AnyDown", "AnyUp")
        pet:SetAttribute("type", "target")
        pet:SetAttribute("unit", "none")

        targetEnemyButtons[i] = target
        targetEnemyPetButtons[i] = pet
        focusEnemyButtons[i] = focus
    end

    -- target bottom
    targetBottomFrameButton = wow.CreateFrame("Button", "FSTargetBottom", wow.UIParent, "SecureActionButtonTemplate")
    targetBottomFrameButton:RegisterForClicks("AnyDown", "AnyUp")
    targetBottomFrameButton:SetAttribute("type", "target")
    targetBottomFrameButton:SetAttribute("unit", "none")

    InitCycleButtons()
end
