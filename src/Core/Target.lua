local _, addon = ...
local fsSort = addon.Sorting
local fsEnumerable = addon.Enumerable
local fsVisual = addon.Visual
local fsLog = addon.Log
local prefix = "FSTarget"
local keybindingsCount = 5
local previousUnits = nil

local function CanUpdate()
    if InCombatLockdown() then
        fsLog:Warning("Can't update targets during combat.")
        return false
    end

    return true
end

local function UpdateTargets()
    local units = fsVisual:GetVisuallyOrderedUnits()

    -- prevent editing macros if the units haven't changed
    if previousUnits and fsEnumerable:ArrayEquals(previousUnits, units) then
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

local function OnLayout()
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
    fsSort:RegisterPostSortCallback(Run)

    if CompactRaidFrameContainer.LayoutFrames then
        hooksecurefunc(CompactRaidFrameContainer, "LayoutFrames", OnLayout)
    elseif CompactRaidFrameContainer_LayoutFrames then
        hooksecurefunc("CompactRaidFrameContainer_LayoutFrames", OnLayout)
    end
end
