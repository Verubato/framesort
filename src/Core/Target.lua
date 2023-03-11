local _, addon = ...
local prefix = "FSTarget"
local keybindingsCount = 5
local eventFrame = nil
local previousUnits = nil
local array = addon.Array

---Updates the targeting hotkeys to the sorted units.
local function UpdateTargets()
    if InCombatLockdown() then
        addon:Debug("Can't update targets during combat.")
        return false
    end

    local units = addon:GetVisuallyOrderedUnits()

    -- prevent editing macros if the units haven't changed
    if previousUnits and array:ArrayEquals(previousUnits, units) then
        return
    end

    addon:Debug("Updating targets.")

    -- if units has less than 5 items it's still fine as units[i] will just be nil
    for i = 1, keybindingsCount do
        local unit = units[i]
        local btn = _G[prefix .. i]

        btn:SetAttribute("unit", unit or "none")
    end

    previousUnits = units

    return true
end

---Initialises the targeting frames feature.
function addon:InitTargeting()
    for i = 1, keybindingsCount do
        local target = CreateFrame("Button", prefix .. i, UIParent, "SecureActionButtonTemplate")
        target:RegisterForClicks("AnyDown")
        target:SetAttribute("type", "target")
        target:SetAttribute("unit", "none")
    end

    eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", UpdateTargets)
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    addon:RegisterPostSortCallback(UpdateTargets)
    hooksecurefunc("FlowContainer_DoLayout", UpdateTargets)
end
