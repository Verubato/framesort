local _, addon = ...
local fsSort = addon.Sorting
local fsMacro = addon.Macro
local fsEnumerable = addon.Enumerable
local fsVisual = addon.Visual
local fsLog = addon.Log
local maxMacros = 138
local isSelfEditingMacro = false
local previousUnits = nil

local function CanUpdate()
    if InCombatLockdown() then
        fsLog:Warning("Can't update macros during combat.")
        return false
    end

    return true
end

local function InspectMacro(slot)
    local _, _, body = GetMacroInfo(slot)

    if not body or not fsMacro:IsFrameSortMacro(body) then return false end

    local units = fsVisual:GetVisuallyOrderedUnits()
    local frameIds = fsMacro:GetFrameIds(body)
    local newBody = fsMacro:GetNewBody(body, frameIds, units)

    if not newBody then return false end

    isSelfEditingMacro = true
    EditMacro(slot, nil, nil, newBody)
    isSelfEditingMacro = false
end

local function ScanMacros()
    local units = fsVisual:GetVisuallyOrderedUnits()

    -- prevent editing macros if the units haven't changed
    if previousUnits and fsEnumerable:ArrayEquals(previousUnits, units) then
        return
    end

    for i = 1, maxMacros do
        InspectMacro(i)
    end

    previousUnits = units
end

local function OnEditMacro(macroInfo, _, _, _)
    -- prevent recursion from EditMacro hook
    if isSelfEditingMacro then return end

    if not CanUpdate() then return end

    InspectMacro(macroInfo)
end

local function OnLayout(container)
    if container ~= CompactRaidFrameContainer then return end
    if container.flowPauseUpdates then return end
    if not CanUpdate() then return end

    ScanMacros()
end

local function Run()
    if not CanUpdate() then return end

    ScanMacros()
end

---Initialises the macros module.
function addon:InitMacros()
    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", Run)
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    fsSort:RegisterPostSortCallback(Run)

    hooksecurefunc("EditMacro", OnEditMacro)
    hooksecurefunc("FlowContainer_DoLayout", OnLayout)
end
