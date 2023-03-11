local _, addon = ...
local maxMacros = 138
local eventFrame = nil
local isSelfEditingMacro = false
local macro = addon.Macro

local function InspectMacro(slot)
    local _, _, body = GetMacroInfo(slot)

    if not body or not macro:IsFrameSortMacro(body) then return false end

    addon:Debug("Found macro at slot " .. slot)

    local units = addon:GetVisuallyOrderedUnits()
    local frameIds = macro:GetFrameIds(body)
    local newBody = macro:GetNewBody(body, frameIds, units)

    if not newBody then return false end

    isSelfEditingMacro = true
    EditMacro(slot, nil, nil, newBody)
    isSelfEditingMacro = false

    addon:Debug("Updated macro at slot " .. slot)
end

function addon:ScanMacros()
    if InCombatLockdown() then
        addon:Debug("Can't update macros during combat.")
        return
    end

    for i = 1, maxMacros do
        InspectMacro(i)
    end
end

local function OnEditMacro(macroInfo, _, _, _)
    -- prevent recursion from EditMacro hook
    if isSelfEditingMacro then return end

    if InCombatLockdown() then
        addon:Debug("Can't update macros during combat.")
        return
    end

    InspectMacro(macroInfo)
end

local function UpdateMacros()
    addon:Debug("Updating macros.")

    addon:ScanMacros()
end

---Initialises the macros module.
function addon:InitMacros()
    eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", UpdateMacros)
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    addon:RegisterPostSortCallback(UpdateMacros)

    hooksecurefunc("EditMacro", OnEditMacro)
    hooksecurefunc("FlowContainer_DoLayout", UpdateMacros)
end
