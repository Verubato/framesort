local _, addon = ...
local prefix = "FSTarget"
local keybindingsCount = 5

---Updates the targeting hotkeys to the sorted units.
local function UpdateTargets()
    if InCombatLockdown() then
        addon:Debug("Can't update targets during combat.")
        return false
    end

    local units = addon:GetUnits()
    local sortFunction = addon:GetSortFunction()

    if sortFunction then
        table.sort(units, sortFunction)
    end

    -- if units has less than 5 items it's still fine as units[i] will just be nil
    for i = 1, keybindingsCount do
        local unit = units[i]
        local btn = _G[prefix .. i]

        btn:SetAttribute("unit", unit)
    end

    return true
end

local function OnSorted()
    UpdateTargets()
end

---Initialises the targeting frames feature.
function addon:InitTargeting()
    for i = 1, keybindingsCount do
        local target = CreateFrame("Button", prefix .. i, UIParent, "SecureActionButtonTemplate")
        target:RegisterForClicks("AnyDown")
        target:SetAttribute("type", "target")
        target:SetAttribute("unit", "none")
    end

    addon:RegisterPostSortCallback(OnSorted)
end

