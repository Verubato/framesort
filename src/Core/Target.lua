local _, addon = ...

local prefix = "FSTarget"

---Initialises the targeting frames feature.
function addon:InitTargeting()
    for i = 1, 5 do
        local target = CreateFrame("Button", prefix .. i, UIParent, "SecureActionButtonTemplate")
        target:RegisterForClicks("AnyDown")
        target:SetAttribute("type", "target")
        target:SetAttribute("unit", "player")
    end
end

---Updates the targeting hotkeys to the sorted units.
function addon:UpdateTargets()
    local units = addon:GetUnits()
    local sortFunction = addon:GetSortFunction()

    if sortFunction then
        table.sort(units, sortFunction)
    end

    addon:SetTargets(units)
end

---Sets the units to use for targeting.
function addon:SetTargets(units)
    addon:Debug("Updating frame targets.")

    for i = 1, 5 do
        local unit = units[i]
        local btn = _G[prefix .. i]

        btn:SetAttribute("unit", unit)
    end
end
