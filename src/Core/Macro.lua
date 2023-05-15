local _, addon = ...
local maxMacros = 138
local eventFrame = nil
local isSelfEditingMacro = false
local macro = addon.Macro
local array = addon.Array
local previousUnits = nil

local function InspectMacro(slot)
    local _, _, body = GetMacroInfo(slot)

    if not body or not macro:IsFrameSortMacro(body) then return false end

    local units = addon:GetVisuallyOrderedUnits()
    local frameIds = macro:GetFrameIds(body)
    local newBody = macro:GetNewBody(body, frameIds, units)

    if not newBody then return false end

    isSelfEditingMacro = true
    EditMacro(slot, nil, nil, newBody)
    isSelfEditingMacro = false
end


local function ScanMacros()
    if InCombatLockdown() then
        addon:Warning("Can't update macros during combat.")
        return
    end

    local units = addon:GetVisuallyOrderedUnits()

    -- prevent editing macros if the units haven't changed
    if previousUnits and array:ArrayEquals(previousUnits, units) then
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

    if InCombatLockdown() then
        addon:Warning("Can't update macros during combat.")
        return
    end

    InspectMacro(macroInfo)
end

local function OnLayout(container)
    if container ~= CompactRaidFrameContainer then return end
    if container.flowPauseUpdates then return end

    ScanMacros()
end

---Initialises the macros module.
function addon:InitMacros()
    eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", ScanMacros)
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    addon:RegisterPostSortCallback(ScanMacros)

    hooksecurefunc("EditMacro", OnEditMacro)
    hooksecurefunc("FlowContainer_DoLayout", OnLayout)
end
