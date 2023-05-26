local _, addon = ...
local prefix = "FSTarget"
local keybindingsCount = 5
local previousUnits = nil
local enumerable = addon.Enumerable

local function CanUpdate()
    if InCombatLockdown() then
        addon:Warning("Can't update targets during combat.")
        return false
    end

    return true
end

local function UpdateTargets()
    local units = addon:GetVisuallyOrderedUnits()

    -- prevent editing macros if the units haven't changed
    if previousUnits and enumerable:ArrayEquals(previousUnits, units) then
        return
    end

    -- if units has less than 5 items it's still fine as units[i] will just be nil
    for i = 1, keybindingsCount do
        local unit = units[i]
        local btn = _G[prefix .. i]

        btn:SetAttribute("unit", unit or "none")
    end

    previousUnits = units

    return true
end

local function OnLayout(container)
    if not container or container:IsForbidden() or not container:IsVisible() then return end
    if container ~= CompactRaidFrameContainer then return end
    if container.flowPauseUpdates then return end
    if not CanUpdate() then return end

    UpdateTargets()
end

local function Run()
    if not CanUpdate() then return end

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

    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", Run)
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    addon:RegisterPostSortCallback(Run)
    hooksecurefunc("FlowContainer_DoLayout", OnLayout)
end
